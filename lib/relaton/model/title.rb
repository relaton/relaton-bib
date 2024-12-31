module Relaton
  module Model
    class Title < TypedTitleString
      model Bib::Title

      mappings[:xml].instance_eval do
        root "title"
        # map_content to: :content # , with: { from: :content_from_xml, to: :content_to_xml }
      end

      # def content_from_xml(model, node)
      #   model.content = TypedTitleString.of_xml(node)
      # end

      # def content_to_xml(model, parent, _doc)
      #   parent << TypedTitleString.to_xml(model.content)
      # end
    end
  end
end
