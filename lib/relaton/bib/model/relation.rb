require_relative "item_base"

module Relaton
  module Bib
    class Relation
      attribute :type, :string, values: %w[
        includes includedIn hasPart partOf merges mergedInto splits splitInto
        instanceOf hasInstance exemplarOf hasExemplar manifestationOf
        hasManifestation reproductionOf hasReproduction reprintOf hasReprint
        expressionOf hasExpression translatedFrom hasTranslation arrangementOf
        hasArrangement abridgementOf hasAbridgement annotationOf hasAnnotation
        draftOfhasDraft preliminaryDraftOf hasPreliminaryDraft revisionDraftOf
        hasRevisionDraft editionOf hasEdition updates updatedBy derivedFrom
        derives describes describedBy catalogues cataloguedBy hasSuccessor
        successorOf adaptedFrom hasAdaptation adoptedFrom adoptedAs reviewOf
        hasReview commentaryOf hasCommentary related hasComplement complementOf
        obsoletes obsoletedBy cites isCitedIn
      ]
      attribute :description, LocalizedMarkedUpString
      attribute :bibitem, ItemBase
      choice(min: 1, max: 1) do
        attribute :locality, Locality, collection: true
        attribute :locality_stack, LocalityStack, collection: true
      end
      choice(min: 1, max: 1) do
        attribute :source_locality, Locality, collection: true
        attribute :source_locality_stack, SourceLocalityStack, collection: true
      end

      xml do
        root "relation"

        map_attribute "type", to: :type
        map_element "description", to: :description
        map_element "bibitem", to: :bibitem
        map_element "locality", to: :locality
        map_element "localityStack", to: :locality_stack
        map_element "sourceLocality", to: :source_locality
        map_element "sourceLocalityStack", to: :source_locality_stack
      end
    end
  end
end
