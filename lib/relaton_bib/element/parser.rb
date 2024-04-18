require "relaton_bib/element/to_string"
require "relaton_bib/element/base"
require "relaton_bib/element/any_element"
require "relaton_bib/element/reference_format"
require "relaton_bib/element/em"
require "relaton_bib/element/strong"
require "relaton_bib/element/sup"
require "relaton_bib/element/sub"
require "relaton_bib/element/tt"
require "relaton_bib/element/underline"
require "relaton_bib/element/strike"
require "relaton_bib/element/smallcap"
require "relaton_bib/element/br"
require "relaton_bib/element/text"
require "relaton_bib/element/citation_type"
require "relaton_bib/element/eref_type"
require "relaton_bib/element/eref"
require "relaton_bib/element/stem"
require "relaton_bib/element/keyword"
require "relaton_bib/element/ruby"
require "relaton_bib/element/xref"
require "relaton_bib/element/hyperlink"
require "relaton_bib/element/hr"
require "relaton_bib/element/pagebreak"
require "relaton_bib/element/bookmark"
require "relaton_bib/element/image"
require "relaton_bib/element/index"
require "relaton_bib/element/alignments"
require "relaton_bib/element/paragraph"
require "relaton_bib/element/note"
require "relaton_bib/element/paragraph_with_footnote"

module RelatonBib
  module Element
    extend self

    #
    # Parse elements of TexElement from Sring or Nokogiri::XML::Element.
    #
    # @param [String, Nokogiri::XML::Element] content
    #
    # @return [Array<RelatonBib::Element::Base>] elements of TextElement
    #
    def parse_text_elements(content)
      Parser.parse_text_elements content_to_node(content)
    end

    def parse_pure_text_elements(content)
      Parser.parse_pure_text_elements content_to_node(content)
    end

    def content_to_node(content)
      content.is_a?(Nokogiri::XML::Element) ? content : Nokogiri::XML.fragment(content)
    end

    module Parser
      extend self
      extend RelatonBib::Parser::XML::Locality

      def parse_children(node, &block)
        node.xpath("text()|*").map(&block).compact
      end

      def parse_node(node)
        send "parse_#{node.name.tr('-', '_')}", node
      end

      def parse_text_elements(node)
        parse_children(node) { |n| parse_text_element n }
      end

      def parse_pure_text_elements(node)
        return [] if node.nil?

        parse_children(node) { |n| parse_pure_text_element n }
      end

      def parse_text_element(node)
        if %w[eref stem keyword ruby xref hyperlink hr pagebreak bookmark imaage
              index index-xref].include? node.name
          parse_node node
        else
          parse_pure_text_element node
        end
      end

      def parse_pure_text_element(node)
        if %w[em strong sub sup tt underline strike smallcap br].include? node.name
          parse_node node
        else
          text = node.to_xml(encoding: "UTF-8")
          Text.new text unless text.strip.empty?
        end
      end

      def parse_em(node)
        content = parse_children(node) { |n| parse_em_element n }
        Em.new(content: content)
      end

      def parse_em_element(node)
        if %w(stem eref xref hyperlink index index-xref).include? node.name
          parse_node(node)
        else
          parse_pure_text_element node
        end
      end

      def parse_eref(node)
        content, args = parse_eref_type node
        Eref.new(content, **args)
      end

      def parse_eref_type(node)
        args = { citeas: node[:citeas], type: node["type"] }
        args[:normative] = node["normative"] if node["normative"]
        args[:alt] = node["alt"] if node["alt"]
        pure_text, citation_type = parse_eref_elements node
        args[:citation_type] = citation_type
        [pure_text, **args]
      end

      def parse_eref_elements(node) # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
        citation_type_args = { locality: [] }
        content = []
        parse_children(node) do |n|
          case n.name
          when "locality"
            citation_type_args[:locality] << locality(n)
          when "localityStack"
            citation_type_args[:locality] << locality_stack(n)
          when "date" then citation_type_args[:date] = n.text
          else
            element = parse_pure_text_element(n)
            content << element if element
          end
        end
        [content, CitationType.new(node[:bibitemid], **citation_type_args)]
      end

      def parse_strong(node)
        Strong.new content: parse_children(node) { |n| parse_strong_element n }
      end
      alias_method :parse_strong_element, :parse_em_element

      def parse_stem(node)
        content = parse_any_elements node
        Stem.new content, node[:type]
      end

      def parse_any_elements(node)
        parse_children(node) { |n| parse_any_element n }
      end

      def parse_any_element(node)
        if node.name == "text"
          Text.new(node.text)
        else
          AnyElement.new node.name, parse_any_elements(node), node.attributes
        end
      end

      def parse_sub(node)
        Sub.new content: parse_pure_text_elements(node)
      end

      def parse_sup(node)
        Sup.new content: parse_pure_text_elements(node)
      end

      def parse_tt(node)
        content = parse_children(node) { |n| parse_tt_element(n) }
        Tt.new content: content
      end

      def parse_tt_element(node)
        if %w[eref xref hyperlink index index-xref].include? node.name
          parse_node node
        else
          parse_pure_text_element(node)
        end
      end

      def parse_underline(node)
        Underline.new(parse_pure_text_elements(node), node[:style])
      end

      def parse_keyword(node)
        content = parse_children(node) { |n| parse_keyword_element n }
        Keyword.new content: content
      end

      def parse_keyword_element(node)
        if %w[index index-xref].include? node.name
          parse_node node
        else
          parse_pure_text_element(node)
        end
      end

      def parse_ruby(node)
        ruby = node.at("./ruby")
        content = ruby ? parse_ruby(node.at("./ruby")) : Text.new(node.text)
        Ruby.new content, parse_ruby_attrs(node)
      end

      def parse_ruby_attrs(node)
        if node&.attr(:annotation)
          Annotation.new node[:annotation], script: node[:script], lang: node[:lang]
        elsif node&.attr(:pronunciation)
          Annotation.new node[:pronunciation], script: node[:script], lang: node[:lang]
        end
      end

      def parse_strike(node)
        content = parse_children(node) { |n| parse_strike_element n }
        Strike.new content: content
      end
      alias_method :parse_strike_element, :parse_keyword_element

      def parse_smallcap(node)
        Smallcap.new content: parse_pure_text_elements(node)
      end

      def parse_xref(node)
        Xref.new(*parse_xref_element(node))
      end

      def parse_xref_element(node)
        content = parse_pure_text_elements(node)
        [content, node[:target], node[:type], node[:alt] ]
      end

      def parse_br(_node)
        Br.new
      end

      # Hyperlink
      def parse_link(node)
        Hyperlink.new(*parse_hyperlink_element(node))
      end
      alias_method :parse_hyperlink_element, :parse_xref_element

      def parse_hr(_node)
        Hr.new
      end

      def parse_pagebreak(_node)
        PageBreak.new
      end

      def parse_bookmark(node)
        Bookmark.new node[:id]
      end

      def parse_image(node)
        Image.new(**node.to_h.transform_keys(&:to_sym))
      end

      def parse_index(node)
        primary = parse_pure_text_elements(node.at("./primary"))
        secondary = parse_pure_text_elements(node.at("./secondary"))
        tertiary = parse_pure_text_elements(node.at("./tertiary"))
        Index.new primary, secondary: secondary, tertiary: tertiary, to: node[:to]
      end

      def parse_index_xref(node)
        primary = parse_pure_text_elements(node.at("./primary"))
        secondary = parse_pure_text_elements(node.at("./secondary"))
        tertiary = parse_pure_text_elements(node.at("./tertiary"))
        target = parse_pure_text_elements(node.at("./target"))
        IndexXref.new primary, secondary: secondary, tertiary: tertiary, target: target, also: node[:also]
      end
    end
  end
end
