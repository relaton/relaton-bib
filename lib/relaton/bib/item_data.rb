module Relaton
  module Bib
    # This class represents the data of a bibliographic item.
    # It needed to keep data fot different types of representations (bibitem, bibdata ...).
    # @TODO: remove this class when Lutaml Model will support transformation between different types of models.
    class ItemData
      include Core::ArrayWrapper

      ATTRIBUTES = %i[
        id type schema_version fetched formattedref docnumber edition status
        medium size validity depiction ext
      ].freeze
      COLLECTION_ATTRBUTES = %i[
        docidentifier date contributor version note language locale script
        copyright series place price extent accesslocation license
        classification keyword
      ].freeze
      COLLECTION_WRITE_ONLY_ATTRIBUTES = %i[title abstract source relation].freeze

      ATTRIBUTES.each { |attr| attr_accessor attr }
      COLLECTION_ATTRBUTES.each { |attr| attr_accessor attr }
      COLLECTION_WRITE_ONLY_ATTRIBUTES.each { |attr| attr_writer attr }

      def initialize(**args)
        ATTRIBUTES.each do |attr|
          instance_variable_set("@#{attr}", args[attr])
        end

        (COLLECTION_ATTRBUTES + COLLECTION_WRITE_ONLY_ATTRIBUTES).each do |attr|
          instance_variable_set("@#{attr}", args[attr] || [])
        end
        self.schema_version = schema
        create_id
      end

      #
      # Fetch schema version
      #
      # @return [String] schema version
      #
      def schema
        @schema ||= Relaton.schema_versions["relaton-models"]
      end

      def to_relation_item
        self.id = nil
        self.schema_version = nil
        self.fetched = nil
        ext&.schema_version = nil
      end

      # remove title part components and abstract
      def to_all_parts # rubocop:disable Metrics/MethodLength
        me = deep_clone
        me.relation ||= []
        to_relation_item
        me.relation << create_relation(type: "instanceOf", bibitem: self)
        me.delete_title_part!
        me.title_update_main
        me.abstract = []
        me.docidentifier.each(&:to_all_parts!)
        me.ext_to_all_parts!
        # me.all_parts = true
        me
      end

      def to_most_recent_reference
        me = deep_clone
        to_relation_item
        me.relation ||= []
        me.relation << create_relation(type: "instanceOf", bibitem: self)
        me.abstract = []
        me.date = []
        me.docidentifier.each(&:remove_date!)
        me.ext_remove_date
        me.create_id without_date: true
        me
      end

      def create_id(without_date: false)
        docid = docidentifier.find(&:primary) || docidentifier.first
        return unless docid

        pubid = without_date ? docid.content.sub(/:\d{4}$/, "") : docid.content
        self.id = pubid.gsub(/\W+/, "")
      end

      def title(lang = nil)
        return @title if lang.nil?

        @title.select { |t| t.language == lang.to_s }
      end

      def abstract(lang = nil)
        return @abstract if lang.nil?

        @abstract.select { |a| a.language == lang.to_s }
      end

      def source(src = nil)
        return @source if src.nil?

        @source.find { |s| s.type == src.to_s }&.content
      end

      def relation(type = nil)
        return @relation if type.nil?

        @relation&.select { |r| r.type == type.to_s }
      end

      def to_xml(bibdata: false, **opts)
        add_notes opts[:note] do
          bibdata ? namespace::Bibdata.to_xml(self) : namespace::Bibitem.to_xml(self)
        end
      end

      def to_yaml(**opts)
        add_notes opts[:note] do
          namespace::Item.to_yaml(self)
        end
      end

      def to_json(**opts)
        add_notes opts[:note] do
          namespace::Item.to_json(self)
        end
      end

      def to_bibtex
        Renderer::BibtexBuilder.build(self).to_s
      end

      def to_rfcxml
        Converter::BibXml.from_item(self).to_xml
      end

      def deep_clone
        namespace::Item.from_yaml namespace::Item.to_yaml(self)
      end

      def create_relation(**args)
        if defined?(namespace::Relation)
          namespace::Relation.new(**args)
        else
          Relation.new(**args)
        end
      end

      def delete_title_part!
        title&.delete_if { |t| t.type == "title-part" }
      end

      def title_update_main # rubocop:disable Metrics/AbcSize,Metrics/CyclomaticComplexity,Metrics/PerceivedComplexity
        language&.each do |lang|
          ttl = title.select { |t| t.type != "main" && t.language == lang }
          next if ttl.empty?

          tm_lang = ttl.map(&:content).join " - "
          title.detect { |t| t.type == "main" && t.language == lang }&.content = tm_lang
        end
      end

      def ext_to_all_parts!
        return unless ext

        # some flavor modles have structuredidentifier as not an array
        # so we need to make it an array use common method
        array(ext.structuredidentifier).each(&:to_all_parts!)
      end

      def ext_remove_date
        return unless ext

        array(ext.structuredidentifier).each(&:remove_date!)
      end

      private

      class << self
        def namespace
          @namespace = Object.const_get name.split("::")[0..1].join("::")
        end
      end

      def namespace
        self.class.namespace
      end

      def add_notes(notes)
        self.note ||= []
        array(notes).each { |nt| note << Bib::Note.new(**nt) }
        result = yield
        array(notes).each { note.pop }
        result
      end
    end
  end
end
