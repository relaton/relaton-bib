module Relaton
  module Model
    class Copyright < Lutaml::Model::Serializable
      model Bib::Copyright

      attribute :from, :string
      attribute :to, :string
      attribute :owner, ContributionInfo, collection: true
      attribute :scope, :string

      xml do
        root "copyright"

        map_element "from", to: :from
        map_element "to", to: :to
        map_element "owner", to: :owner # , with: { from: :owner_from_xml, to: :owner_to_xml }
        map_element "scope", to: :scope
      end

      def owner_from_xml(model, node)
        model.owner = ContributionInfo.from_xml node
      end

      def owner_to_xml(model, parent, _doc)
        model.owner.to_xml parent
      end
    end
  end
end
