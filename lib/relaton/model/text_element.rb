module Relaton
  module Model
    module TextElement
      def self.included(base) # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
        base.class_eval do # rubocop:disable Metrics/BlockLength
          attribute :em, Em
          # attribute :eref, Eref
          # attribute :strong, Strong
          # attribute :stem, Stem
          # attribute :sub, Sub
          # attribute :sup, Sup
          # attribute :tt, Tt
          # attribute :underline, Underline
          # attribute :keyword, Keyword
          # attribute :ruby, Ruby
          # attribute :strike, Strike
          # attribute :smallcap, Smallcap
          # attribute :xref, Xref
          # attribute :br, Br
          # attribute :hyperlink, Hyperlink
          # attribute :hr, Hr
          # attribute :pagebreak, Pagebreak
          # attribute :bookmark, Bookmark
          # attribute :image, Image
          # attribute :index, Index
          # attribute :index_xref, IndexXref

          xml do
            map_element "em", to: :em
            # map_element "eref", to: :eref
            # map_element "strong", to: :strong
            # map_element "stem", to: :stem
            # map_element "sub", to: :sub
            # map_element "sup", to: :sup
            # map_element "tt", to: :tt
            # map_element "underline", to: :underline
            # map_element "keyword", to: :keyword
            # map_element "ruby", to: :ruby
            # map_element "strike", to: :strike
            # map_element "smallcap", to: :smallcap
            # map_element "xref", to: :xref
            # map_element "br", to: :br
            # map_element "hyperlink", to: :hyperlink
            # map_element "hr", to: :hr
            # map_element "pagebreak", to: :pagebreak
            # map_element "bookmark", to: :bookmark
            # map_element "image", to: :image
            # map_element "index", to: :index
            # map_element "index-xref", to: :index_xref
          end
        end
      end
    end
  end
end
