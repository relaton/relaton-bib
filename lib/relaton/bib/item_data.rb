module Relaton
  module Bib
    # This class represents the data of a bibliographic item.
    # It needed to keep data fot different types of representations (bibitem, bibdata ...).
    # @TODO: remove this class when Lutaml Model will support transformation between different types of models.
    class ItemData
      attr_accessor :id, :type, :schema_version, :fetched, :formattedref, :title,
                    :source, :docidentifier, :docnumber, :date, :contributor,
                    :edition, :version, :note, :language, :locale, :script,
                    :abstract, :status, :copyright, :relation, :series, :medium,
                    :place, :price, :extent, :size, :accesslocation, :license,
                    :classification, :keyword, :validity, :depiction, :ext, :all_parts

      def initialize(**args)
        args.each { |k, v| instance_variable_set "@#{k}", v }
      end

      # remove title part components and abstract
      def to_all_parts # rubocop:disable Metrics/MethodLength
        me = deep_clone
        # me.disable_id_attribute
        me.relation ||= []
        me.relation << create_relation(type: "instanceOf", bibitem: self)
        me.delete_title_part!
        me.title_update_main
        me.abstract = []
        me.docidentifier.each(&:to_all_parts)
        me.ext_to_all_parts
        me.all_parts = true
        me
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

      def ext_to_all_parts
        return unless ext

        # some flavor modles have structuredidentifier as not an array
        # so we need to make it an array use common method
        Relaton.array(ext.structuredidentifier).each(&:to_all_parts)
      end

      # def disable_id_attribute
      #   @id_attribute = false
      # end
    end
  end
end
