module Relaton
  module Bib
    class LocalizedStringAttrs < Lutaml::Model::Serializable
      attribute :language, :string
      attribute :locale, :string
      attribute :script, :string

      # def self.inherited(base)
      #   super
      #   base.class_eval do
      xml do
        map_attribute "language", to: :language
        map_attribute "locale", to: :locale
        map_attribute "script", to: :script
      end
      #   end
      # end
    end
  end
end
