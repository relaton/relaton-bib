module Relaton
  module Bib
    class Version < Lutaml::Model::Serializable
      attribute :type, :string
      attribute :content, :string
      attribute :revision_date, :string
      attribute :draft, :string

      xml do
        root "version"
        map_attribute "type", to: :type
        map_content to: :content
        map_element "revision-date", to: :revision_date
        map_element "draft", to: :draft
      end

      key_value do
        map "type", to: :type
        map "content", to: :content
        map "revision_date", to: :revision_date
        map "draft", to: :draft
      end

      def content
        return @content if @content && !@content.empty?

        parts = [@draft, @revision_date].compact
        case parts.size
        when 2 then "#{@draft} (#{@revision_date})"
        when 1 then parts.first
        end
      end

      def revision_date
        nil
      end

      def draft
        nil
      end
    end
  end
end
