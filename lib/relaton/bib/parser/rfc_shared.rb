module Relaton
  module Bib
    module Parser
      module RfcShared
        def source # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
          s = []
          s << Uri.new(type: "src", content: @reference.target) if @reference.target
          # if /^I-D/.match? @reference.anchor
          #   @reference.format.each do |f|
          #     s << Uri.new(type: f.type, content: f.target)
          #   end
          # end
          return s unless @reference.respond_to?(:front) && @reference.front

          (@reference.format || []).each do |fr|
            s << Uri.new(type: fr.type, content: fr.target)
          end
          s
        end
      end
    end
  end
end
