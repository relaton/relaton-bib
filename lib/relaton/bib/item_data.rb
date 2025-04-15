module Relaton
  module Bib
    # This class represents the data of a bibliographic item.
    # It needed to keep data fot different types of representations (bibitem, bibdata ...).
    # @TODO: remove this class when Lutaml Model will support transformation between different types of models.
    class ItemData
      attr_accessor :id, :type, :schema_version, :fetched, :formattedref,
                    :docidentifier, :docnumber, :date, :contributor, :edition,
                    :version, :note, :language, :locale, :script, :status,
                    :copyright, :series, :medium, :place, :price, :extent,
                    :size, :accesslocation, :license, :classification,
                    :keyword, :validity, :depiction, :ext # , :all_parts

      attr_writer :title, :abstract, :source, :relation

      def initialize(**args)
        args.each do |k, v|
          instance_variable_set("@#{k}", v) if respond_to?("#{k}=")
        end
        self.schema_version = schema
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
        raise NotImplementedError, "`create_id` method not implemented in #{self.class}"
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

      def to_xml(bibdata: false)
        bibdata ? Bibdata.to_xml(self) : Bibitem.to_xml(self)
      end

      def to_bibtex
        Renderer::BibtexBuilder.build(self).to_s
      end

      def deep_clone
        Item.from_yaml Item.to_yaml(self)
      end

      def create_relation(**args)
        Relation.new(**args)
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
        Relaton.array(ext.structuredidentifier).each(&:to_all_parts!)
      end

      def ext_remove_date
        return unless ext

        Relaton.array(ext.structuredidentifier).each(&:remove_date!)
      end

      # def disable_id_attribute
      #   @id_attribute = false
      # end
    end
  end
end
