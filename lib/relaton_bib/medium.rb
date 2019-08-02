module RelatonBib
  class Medium
    # @return [String, NilClass]
    attr_reader :form, :size, :scale

    # @param form [String, NilClass]
    # @param size [String, NilClass]
    # @param scale [String, NilClass]
    def initialize(form: nil, size: nil, scale: nil)
      @form  = form
      @size  = size
      @scale = scale
    end

    # @param builder [Nokogiri::XML::Builder]
    def to_xml(builder)
      builder.medium do
        builder.form form if form
        builder.size size if size
        builder.scale scale if scale
      end
    end
  end
end
