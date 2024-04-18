module RelatonBib
  module Element
    #
    # Ruby element contains two elements: pronunciation/annotation and text/ruby.
    #
    class Ruby
      include ToString

      # @return [RelatonBib::Element::Pronunciation, RelatonBib::Element::Annotation]
      attr_reader :annotation

      # @return [RelatonBib::Element::Text, RelatonBib::Element::Ruby]
      attr_reader :content

      #
      # Initialize Ruby element
      #
      # @param [RelatonBib::Element::Text, RelatonBib::Element::Ruby] content
      # @param [RelatonBib::Element::Pronunciation, RelatonBib::Element::Annotation] annotation annotation or pronunciation
      #
      def initialize(content, annotation)
        @annotation = annotation
        @content = content
      end

      # @param builder [Nokogiri::XML::Builder]
      def to_xml(builder)
        builder.ruby do |b|
          annotation.to_xml b
          content.to_xml b
        end
      end
    end

    class Annotation
      include ToString

      # @return [String]
      attr_reader :value

      # @return [String, nil]
      attr_reader :script, :lang

      #
      # Initialize Annotation element
      #
      # @param [String] value
      # @param [String, nil] script
      # @param [String, nil] lang
      #
      def initialize(value, script: nil, lang: nil)
        @value = value
        @script = script
        @lang = lang
      end

      # @param builder [Nokogiri::XML::Builder]
      def to_xml(builder)
        builder.annotation value: value, script: script, lang: lang
      end
    end

    class Pronunciation < RelatonBib::Element::Annotation
      # @param builder [Nokogiri::XML::Builder]
      def to_xml(builder)
        builder.pronunciation value: value, script: script, lang: lang
      end
    end
  end
end
