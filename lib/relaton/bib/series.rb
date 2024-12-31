# frozen_string_literal: true

module Relaton
  module Bib
    #
    # Series class.
    #
    class Series
      # TYPES = %w[main alt].freeze

      # @return [String, nil] allowed values: "main" or "alt"
      attr_accessor :type

      # @return [Relaton::Bib::Formattedref, nil]
      attr_accessor :formattedref

      # @return [Relaton::Bib::TitleCollection] title
      attr_accessor :title

      # @return [Relaton::Bib::Place, nil]
      attr_accessor :place

      # @return [String, nil]
      attr_accessor :organization, :from, :to, :number, :partnumber, :run

      # @return [Relaton::Bib::LocalizedString, nil]
      attr_accessor :abbreviation

      # @param type [String, nil] allowed values: "main" or "alt"
      # @param formattedref [Relaton::Bib::Formattedref, nil]
      # @param title [Relaton::Bib::TitleCollection] title
      # @param place [Relation::Bib::Place, nil]
      # @param orgaization [String, nil]
      # @param abbreviation [Relaton::Bib::LocalizedString, nil]
      # @param from [String, nil]
      # @param to [String, nil]
      # @param number [String, nil]
      # @param partnumber [String, nil]
      # @param run [String, nil]
      def initialize(**args) # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
        # if args[:type] && !TYPES.include?(args[:type])
        #   warn "[relaton-bib] Series type is invalid: #{args[:type]}"
        # end

        @type         = args[:type] # if %w[main alt].include? args[:type]
        @title        = args[:title]
        @formattedref = args[:formattedref]
        @place        = args[:place]
        @organization = args[:organization]
        @abbreviation = args[:abbreviation]
        @from         = args[:from]
        @to           = args[:to]
        @number       = args[:number]
        @partnumber   = args[:partnumber]
        @run          = args[:run]
      end

      # @param builder [Nokogiri::XML::Builder]
      # def to_xml(builder) # rubocop:disable Metrics/MethodLength
      #   xml = builder.series do
      #     formattedref&.to_xml builder
      #     builder.title { title.to_xml builder }
      #     builder.place place if place
      #     builder.organization organization if organization
      #     builder.abbreviation { abbreviation.to_xml builder } if abbreviation
      #     builder.from from if from
      #     builder.to to if to
      #     builder.number number if number
      #     builder.partnumber partnumber if partnumber
      #     builder.run run if run
      #   end
      #   xml[:type] = type if type
      # end

      # @return [Hash]
      # def to_hash # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength, Metrics/PerceivedComplexity
      #   hash = {}
      #   hash["type"] = type if type
      #   hash["formattedref"] = formattedref.to_hash if formattedref
      #   hash["title"] = title.to_hash
      #   hash["place"] = place if place
      #   hash["organization"] = organization if organization
      #   hash["abbreviation"] = abbreviation.to_hash if abbreviation
      #   hash["from"] = from if from
      #   hash["to"] = to if to
      #   hash["number"] = number if number
      #   hash["partnumber"] = partnumber if partnumber
      #   hash["run"] = run if run
      #   hash
      # end

      # @param prefix [String]
      # @param count [Integer]
      # @return [String]
      def to_asciibib(prefix = "", count = 1) # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength,Metrics/PerceivedComplexity
        pref = prefix.empty? ? "series" : prefix + ".series"
        out = count > 1 ? "#{pref}::\n" : ""
        out += "#{pref}.type:: #{type}\n" if type
        out += formattedref.to_asciibib pref if formattedref
        out += title.to_asciibib pref
        out += "#{pref}.place:: #{place}\n" if place
        out += "#{pref}.organization:: #{organization}\n" if organization
        out += abbreviation.to_asciibib "#{pref}.abbreviation" if abbreviation
        out += "#{pref}.from:: #{from}\n" if from
        out += "#{pref}.to:: #{to}\n" if to
        out += "#{pref}.number:: #{number}\n" if number
        out += "#{pref}.partnumber:: #{partnumber}\n" if partnumber
        out += "#{pref}.run:: #{run}\n" if run
        out
      end
    end
  end
end
