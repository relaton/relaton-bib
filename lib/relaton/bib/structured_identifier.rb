module Relaton
  module Bib
    class StructuredIdentifierCollection
      # include Relaton
      extend Forwardable

      def_delegators :@collection, :any?, :size, :[], :detect, :map, :each,
                     :reduce

      # @param collection [Array<Relaton::Bib::StructuredIdentifier>]
      def initialize(collection = [])
        @collection = collection
      end

      # @param builder [Nokogiri::XML::Builder]
      def to_xml(builder)
        @collection.each { |si| si.to_xml builder }
      end

      # @return [Array<Hash>]
      def to_hash
        single_element_array @collection
      end

      # @param prefix [String]
      # @return [String]
      def to_asciibib(prefix = "")
        pref = prefix.empty? ? prefix : "#{prefix}."
        pref += "structured_identifier"
        @collection.reduce("") do |out, si|
          out += "#{pref}::\n" if @collection.size > 1
          out + si.to_asciibib(pref)
        end
      end

      # remoe year from docnumber
      def remove_date
        @collection.each &:remove_date
      end

      def remove_part
        @collection.each &:remove_part
      end

      def all_parts
        @collection.each &:all_parts
      end

      def presence?
        any?
      end

      # This is needed for lutaml-model to treat RelationCollection instance as Array
      def is_a?(klass)
        klass == Array || super
      end

      # @return [Relaton::Bib::StructuredIdentifierCollection]
      # def map(&block)
      #   StructuredIdentifierCollection.new @collection.map &block
      # end
    end

    class StructuredIdentifier
      # include Relaton

      ARGS = %i[docnumber type agency class partnumber edition version
                supplementtype supplementnumber amendment corrigendum
                language year].freeze

      ARGS.each { |attr| attr_accessor attr }

      # @param docnumber [String]
      # @param type [String, nil]
      # @param agency [Array<String>]
      # @param class [Stirng, nil]
      # @param partnumber [String, nil]
      # @param edition [String, nil]
      # @param version [String, nil]
      # @param supplementtype [String, nil]
      # @param supplementnumber [String, nil]
      # @param amendment [String, nil]
      # @param corrigendum [String, nil]
      # @param language [String, nil]
      # @param year [String, nil]
      def initialize(**args)
        ARGS.each { |attr| instance_variable_set "@#{attr}", args[attr] }
        # @type = args[:type]
        # @agency = args[:agency]
        # @klass = args[:class]
        # @docnumber = args[:docnumber]
        # @partnumber = args[:partnumber]
        # @edition = args[:edition]
        # @version = args[:version]
        # @supplementtype = args[:supplementtype]
        # @supplementnumber = args[:supplementnumber]
        # @language = args[:language]
        # @year = args[:year]
      end

      # @param builder [Nokogiri::XML::Builder]
      # def to_xml(builder)
      #   xml = builder.structuredidentifier do |b|
      #     agency&.each { |a| b.agency a }
      #     b.class_ klass if klass
      #     b.docnumber docnumber
      #     b.partnumber partnumber if partnumber
      #     b.edition edition if edition
      #     b.version version if version
      #     b.supplementtype supplementtype if supplementtype
      #     b.supplementnumber supplementnumber if supplementnumber
      #     b.language language if language
      #     b.year year if year
      #   end
      #   xml[:type] = type if type
      # end

      # @return [Hash]
      # def to_hash
      #   hash = { "docnumber" => docnumber }
      #   hash["type"] = type if type
      #   hash["agency"] = single_element_array agency if agency&.any?
      #   hash["class"] = klass if klass
      #   hash["partnumber"] = partnumber if partnumber
      #   hash["edition"] = edition if edition
      #   hash["version"] = version if version
      #   hash["supplementtype"] = supplementtype if supplementtype
      #   hash["supplementnumber"] = supplementnumber if supplementnumber
      #   hash["language"] = language if language
      #   hash["year"] = year if year
      #   hash
      # end

      # @param prefix [String]
      # @return [String]
      def to_asciibib(prefix) # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength,Metrics/PerceivedComplexity
        out = "#{prefix}.docnumber:: #{docnumber}\n"
        agency.each { |a| out += "#{prefix}.agency:: #{a}\n" }
        out += "#{prefix}.type:: #{type}\n" if type
        out += "#{prefix}.class:: #{klass}\n" if klass
        out += "#{prefix}.partnumber:: #{partnumber}\n" if partnumber
        out += "#{prefix}.edition:: #{edition}\n" if edition
        out += "#{prefix}.version:: #{version}\n" if version
        out += "#{prefix}.supplementtype:: #{supplementtype}\n" if supplementtype
        if supplementnumber
          out += "#{prefix}.supplementnumber:: #{supplementnumber}\n"
        end
        out += "#{prefix}.language:: #{language}\n" if language
        out += "#{prefix}.year:: #{year}\n" if year
        out
      end

      def remove_date
        if @type == "Chinese Standard"
          @docnumber.sub!(/-[12]\d\d\d/, "")
        else
          @docnumber.sub!(/:[12]\d\d\d/, "")
        end
        @year = nil
      end

      # in docid manipulations, assume ISO as the default: id-part:year
      def remove_part
        @partnumber = nil
        @docnumber = @docnumber.sub(/-\d+/, "")
      end

      def all_parts
        @docnumber = "#{@docnumber} (all parts)"
      end
    end
  end
end
