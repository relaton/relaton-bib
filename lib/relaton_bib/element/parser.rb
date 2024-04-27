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
require "relaton_bib/element/index"
require "relaton_bib/element/alignments"
require "relaton_bib/element/paragraph"
require "relaton_bib/element/note"
require "relaton_bib/element/paragraph_with_footnote"
require "relaton_bib/element/table"
require "relaton_bib/element/tname"
require "relaton_bib/element/thead"
require "relaton_bib/element/tbody"
require "relaton_bib/element/tfoot"
require "relaton_bib/element/tr"
require "relaton_bib/element/th"
require "relaton_bib/element/td"
require "relaton_bib/element/dl"
require "relaton_bib/element/dt"
require "relaton_bib/element/dd"
require "relaton_bib/element/formula"
require "relaton_bib/element/admonition"
require "relaton_bib/element/ul"
require "relaton_bib/element/ol"
require "relaton_bib/element/li"
require "relaton_bib/element/figure"
require "relaton_bib/element/source"
require "relaton_bib/element/fn"
require "relaton_bib/element/media"
require "relaton_bib/element/altsource"
require "relaton_bib/element/image"
require "relaton_bib/element/video"
require "relaton_bib/element/audio"
require "relaton_bib/element/pre"
require "relaton_bib/element/quote"
require "relaton_bib/element/callout"
require "relaton_bib/element/annotation"
require "relaton_bib/element/sourcecode"
require "relaton_bib/element/example"
require "relaton_bib/element/review"
require "relaton_bib/element/classification"
require "relaton_bib/element/amend"

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

    def parse_basic_block_elements(content)
      Parser.parse_basic_block_elements content_to_node(content)
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

      def parse_basic_block_elements(node)
        parse_children(node) { |n| parse_basic_block_element n }
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

      def parse_basic_block_element(node)
        if %w[p table formula admonition ol ul dl figure quote
              sourcecode example review pre note pagebreak hr bookmark amend].include? node.name
          parse_node node
        else
          parse_pure_text_element node
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
        Eref.new(**parse_eref_type(node))
      end

      def parse_eref_type(node)
        args = { citeas: node[:citeas], type: node["type"] }
        args[:normative] = node["normative"] if node["normative"]
        args[:alt] = node["alt"] if node["alt"]
        pure_text, citation_type = parse_eref_elements node
        args[:content] = pure_text
        args[:citation_type] = citation_type
        args
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
          Ruby::Annotation.new node[:annotation], script: node[:script], lang: node[:lang]
        elsif node&.attr(:pronunciation)
          Ruby::Pronunciation.new node[:pronunciation], script: node[:script], lang: node[:lang]
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
        [content, node[:target], node[:type], node[:alt]]
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

      def parse_paragraph(node)
        return unless node

        attrs = node.attributes.transform_keys(&:to_sym)
        content = parse_text_elements(node)
        Paragraph.new(content: content, note: parse_notes(node), **attrs)
      end

      def parse_notes(node)
        node.xpath("./note").map { |n| parse_note n }
      end

      def parse_note(node)
        content = node.xpath("./p").map { |n| parse_paragraph n }
        Note.new content: content, id: node[:id]
      end

      def parse_table(node) # rubocop:disable Metrics/AbcSize
        attrs = node.attributes.transform_keys(&:to_sym)
        tname = parse_tname(node.at("./tname"))
        thead = parse_thead(node.at("./thead"))
        tfoot = parse_tfoot(node.at("./tfoot"))
        tbody = parse_tbody(node.at("./tbody"))
        note = node.xpath("./note").map { |n| parse_table_note n }
        Table.new(**attrs, tname: tname, thead: thead, tfoot: tfoot, tbody: tbody, note: note)
      end

      def parse_tname(node)
        return unless node

        content = parse_children(node) { |n| parse_tname_element n }
        Tname.new content: content
      end

      def parse_tname_element(node)
        if %w[eref xref hyperlink index index-xref].include? node.name
          parse_node node
        else
          parse_pure_text_elements(node)
        end
      end

      def parse_thead(node)
        return unless node

        Thead.new content: parse_tr(node.at("./tr"))
      end

      def parse_tfoot(node)
        return unless node

        Tfoot.new content: parse_tr(node.at("./tr"))
      end

      def parse_tbody(node)
        content = node.xpath("./tr").map { |n| parse_tr n }
        Tbody.new content: content
      end

      def parse_table_note(node)
        Table::Note.new content: parse_paragraph(node.at("./p"))
      end

      def parse_tr(node)
        return unless node

        content = parse_children(node) { |n| parse_tr_element n }
        Tr.new content: content
      end

      def parse_tr_element(node)
        %w[th td].include?(node.name) ?  parse_node(node) : parse_pure_text_elements(node)
      end

      def parse_th(node)
        content = parse_children(node) { |n| parse_th_element n }
        attrs = node.attributes.transform_keys(&:to_sym)
        Th.new(content: content, **attrs)
      end

      def parse_th_element(node)
        node.name == "p" ?  parse_paragraph_with_footnote(node) : parse_pure_text_elements(node)
      end

      def parse_td(node)
        content = parse_children(node) { |n| parse_td_element n }
        attrs = node.attributes.transform_keys(&:to_sym)
        Td.new(content: content, **attrs)
      end
      alias_method :parse_td_element, :parse_th_element

      def parse_dl(node)
        content = node.xpath("./dt|./dd").map { |n| parse_dt_dd n }
        Dl.new content: content, id: node[:id], note: parse_notes(node)
      end

      def parse_dt_dd(node)
        if node.name == "dd"
          content = parse_children(node) do |n|
            parse_paragraph_with_footnote(n)
          end
          Dd.new content: content
        else
          Dt.new content: parse_text_elements(node)
        end
      end

      #
      # Parase paragraph with footnote.
      #
      # @param [Nokogiri::XML::Element] node
      #
      # @return [RelatonBib::Element::ParagraphWithFootnote]
      #
      def parse_p(node)
        attrs = node.attributes.transform_keys(&:to_sym)
        content = parse_children(node) do |n|
          parse_paragraph_with_footnote_element n
        end
        ParagraphWithFootnote.new(content: content, note: parse_notes(node), **attrs)
      end

      def parse_paragraph_with_footnote_element(node)
        node.name == "fn" ? parse_fn(node) : parse_text_element(node)
      end

      def parse_formula(node)
        stem = parse_stem(node.at("./stem"))
        note = node.xpath("./note").map { |n| parse_note n }
        attrs = node.attributes.transform_keys(&:to_sym)
        Formula.new id: node[:id], stem: stem, note: note, **attrs
      end

      def parse_admonition(node)
        attrs = node.attributes.transform_keys(&:to_sym)
        content = parse_children(node) { |n| parse_admonition_element n }
        tname = parse_tname(node.at("./tname"))
        note = parse_notes(node)
        Admonition.new(content: content, note: note, tname: tname, **attrs)
      end

      def parse_ol(node)
        content = node.xpath("./li").map { |n| parse_li n }
        note = parse_notes(node)
        Ol.new content: content, id: node[:id], type: node[:type], note: note, start: node[:start]
      end

      def parse_li(node)
        content = parse_children(node) { |n| parse_paragraph_with_footnote n }
        Li.new content: content, id: node[:id]
      end

      def parse_ul(node)
        content = node.xpath("./li").map { |n| parse_li n }
        note = parse_notes(node)
        Ul.new content: content, id: node[:id], note: note
      end

      def parse_figure(node) # rubocop:disable Metrics/AbcSize
        attrs = node.to_h.transform_keys(&:to_sym)
        content = parse_figure_content n
        source = parse_source(node.at("./source"))
        tname = parse_tname(node.at("./tname"))
        fn = node.xpath("./fn").map { |n| parse_fn n }
        dl = parse_dl(node.at("./dl"))
        note = parse_notes(node)
        Figure.new(content: content, source: source, tname: tname, fn: fn, dl: dl, note: note, **attrs)
      end

      def parse_figure_content(node) # rubocop:disable Metrics/AbcSize,Metrics/CyclomaticComplexity,Metrics/MethodLength,Metrics/PerceivedComplexity
        if (node = node.at("./image")) then parse_image node
        elsif (node = node.at("./video")) then parse_video node
        elsif (node = node.at("./audio")) then parse_audio node
        elsif (node = node.at("./pre")) then parse_pre node
        elsif (nodes = node.xpath("./p")).any?
          nodes.map { |n| parse_paragraph_with_footnote n }
        elsif (nodes = node.xpath("./figure")).any?
          nodes.map { |n| parse_figure n }
        end
      end

      def parse_source(node)
        return unless node

        attrs = node.to_h.transform_keys(&:to_sym)
        Element::Source.new(content: node.text, **attrs)
      end

      def parse_fn(node)
        content = parse_children(node) { |n| parse_paragraph n }
        Fn.new reference: node[:reference], content: content
      end

      def parse_video(node)
        attrs = node.to_h.transform_keys(&:to_sym)
        content = node.xpath("./altsource").map { |n| parse_altsource n }
        Video.new(content: content, **attrs)
      end

      def parse_audio(node)
        attrs = node.to_h.transform_keys(&:to_sym)
        content = node.xpath("./altsource").map { |n| parse_altsource n }
        Audio.new(content: content, **attrs)
      end

      def parse_alitsource(node)
        attrs = node.to_h.transform_keys(&:to_sym)
        Altsource.new(**attrs)
      end

      def parse_pre(node)
        content = node.xpath("./note").map { |n| parse_note n }
        content = Text.new node.text if content.empty?
        tname = parse_tname(node.at("./tname"))
        Pre.new id: node[:id], content: content, alt: node[:alt], tname: tname
      end

      def parse_quote(node)
        attrs = node.attributes.transform_keys(&:to_sym)
        content = parse_children(node) { |n| parse_quote_element n }
        source = parse_quote_source(node.at("./source"))
        author = parse_quote_author(node.at("./author"))
        note = parse_notes(node)
        Quote.new(content: content, note: note, source: source, author: author, **attrs)
      end

      def parse_quote_source(node)
        return unless node

        Source.new(**parse_eref_type(node))
      end

      def parse_quote_author(node)
        return unless node

        Author.new Texn.new(node.text)
      end

      def parse_sourcecode(node) # rubocop:disable Metrics/AbcSize
        content = parse_children(node) { |n| parse_sourcecode_element n }
        annotation = node.xpath("./annotation").map { |n| parse_annotation n }
        note = node.xpath("./note").map { |n| parse_note n }
        attrs = node.attributes.transform_keys(&:to_sym)
        tname = parse_tname(node.at("./tname"))
        Sourcecode.new(content: content, annotation: annotation, note: note, tname: tname, **attrs)
      end

      def parse_sourcecode_element(node)
        if node.name == "callout"
          parse_callout node
        elsif node.name == "text"
          Text.new node.text
        end
      end

      def parse_callout(node)
        content = Text.new node.text
        Callout.new content: content, id: node[:id]
      end

      def parse_annotation(node)
        content = parse_paragraph node.at("./p")
        Annotation.new id: node[:id], content: content
      end

      def parse_example(node)
        attrs = node.attributes.transform_keys(&:to_sym)
        content = parse_children(node) { |n| parse_example_element n }
        tname = parse_tname(node.at("./tname"))
        note = parse_notes(node)
        Example.new(content: content, tname: tname, note: note, **attrs)
      end

      def parse_example_element(node)
        if %w[formula ul ol dl quote sourcecode p].include? node.name
          parse_node node
        end
      end

      def parse_review(node)
        attrs = node.attributes.transform_keys(&:to_sym)
        content = node.xpath("./p").map { |n| parse_paragraph n }
        Review.new(content: content, **attrs)
      end

      def parse_amend(node)
        attrs = node.attributes.transform_keys(&:to_sym)
        classification = node.xpath("./classification").map { |n| parse_classification n }
        contributor = Parser::XML.parse_contributors(node)
        location = parse_amend_location(node.at("./location"))
        description = parse_amend_description(node.at("./description"))
        newcontent = parse_amend_newcontent(node.at("./newcontent"))
        Amend.new(classification: classification, contributor: contributor, location: location,
                  description: description, newcontent: newcontent, **attrs)
      end

      def parse_classification(node)
        tag = parse_tag(node.at("./tag"))
        value = parse_value(node.at("./value"))
        Element::Classification.new(tag: tag, value: value)
      end

      def parse_amend_location(node)
        return unless node

        localities(node)
      end

      def parse_amend_description(node)
        return unless node

        content = parse_basic_block_elements(node)
        Element::AmeT::Description.new content: content
      end

      def parse_amend_newcontent(node)
        return unless node

        content = parse_basic_block_elements(node)
        Element::AmendType::Newcontent.new content: content, id: node[:id]
      end
    end
  end
end
