module Relaton
  module Model
    class Strong < Shale::Mapper
      class Content < Shale::Mapper
      end
      attribute :content, Content

      xml do
        map_content to: :content
      end
    end
  end
end
