require "relaton_bib/element/base"
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

module RelatonBib
  module Element
    #
    # Parse elements of TexElement from Sring or Nokogiri::XML::Element.
    #
    # @param [String, Nokogiri::XML::Element] content
    #
    # @return [Array<RelatonBib::Element::Base>] elements of TextElement
    #
    def self.parse_text_elements(content)
      node = content.is_a?(Nokogiri::XML::Element) ? content : Nokogiri::XML.fragment(content)
      Parser.parse_text_elements(node)
    end

    module Parser
      extend self

      #
      # Parse elements of TextElement from Nokogiri::XML::Element.
      #
      # @param [Nokogiri::XML::Element] node
      #
      # @return [Array<RelatonBib::Element::Base>] elements of TextElement
      #
      def parse_text_elements(node)
        parse_children(node) { |n| parse_text_element n }
      end

      def parse_children(element, &block)
        element.xpath("text()|*").map(&block)
      end

      def parse_text_element(node) # rubocop:disable Metrics/AbcSize,Metrics/CyclomaticComplexity,Metrics/MethodLength
        case node.name
        when "em" then Em.new parse_em(node)
        when "eref" then create_eref(node)
        when "strong" then Strong.new parse_children(node)
        when "sub" then Sub.new parse_children(node)
        when "sup" then Sup.new parse_children(node)
        when "tt" then Tt.new parse_children(node)
        when "underline" then Underline.new parse_children(node), node["style"]
        when "strike" then Strike.new parse_children
        when "smallcap" then Smallcap.new parse_children
        when "br" then Br.new
        when "hyperlink" then parse_hyperlink
        else Text.new(node.to_xml(encoding: "UTF-8"))
        end
      end

      def create_eref(element)
        Eref.new(**parse_eref_type(element))
      end

      def parse_eref_type(element)
        args = { citeas: element[:citeas], type: element["type"] }
        args[:normative] = element["normative"] if element["normative"]
        args[:alt] = element["alt"] if element["alt"]
        args.merge parse_citation_type(element)
        args[:content] = parse_pure_text(element)
        args
      end

      def parse_citation_type(element)
        args = { bibitemid: element[:bibitemid] }
        locality = element.xpath("locality").map do |l|
          Locality.new(l[:type])
        end
        args
      end
    end
  end
end
