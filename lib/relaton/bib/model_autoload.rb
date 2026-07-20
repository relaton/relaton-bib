# Central autoload manifest for the model + converter layer.
#
# Declaring these as autoloads (instead of a require_relative chain) makes load
# order irrelevant and removes the circular require between OrganizationType and
# Subdivision (issue #120): a constant is loaded on first reference rather than
# at file-load time, so mutually-referencing classes resolve each other lazily.
#
# lutaml-model must be available before the first model autoload fires, and the
# XML adapter must be configured eagerly here (not inside item.rb) so that
# serializing through any model class works regardless of which one is
# referenced first.
require "lutaml/model"
require "lutaml/xml"

Lutaml::Model::Config.configure do |config|
  config.xml_adapter_type = :nokogiri
end

module Relaton
  module Bib
    autoload :Abstract, "relaton/bib/model/abstract"
    autoload :Address, "relaton/bib/model/address"
    autoload :Affiliation, "relaton/bib/model/affiliation"
    autoload :Bibdata, "relaton/bib/model/bibdata"
    autoload :BibdataShared, "relaton/bib/model/bibdata_shared"
    autoload :Bibitem, "relaton/bib/model/bibitem"
    autoload :BibitemShared, "relaton/bib/model/bibitem_shared"
    autoload :Contact, "relaton/bib/model/contact"
    autoload :ContributionInfo, "relaton/bib/model/contribution_info"
    autoload :Contributor, "relaton/bib/model/contributor"
    autoload :Copyright, "relaton/bib/model/copyright"
    autoload :Date, "relaton/bib/model/date"
    autoload :Depiction, "relaton/bib/model/depiction"
    autoload :Docidentifier, "relaton/bib/model/docidentifier"
    autoload :Doctype, "relaton/bib/model/doctype"
    autoload :Edition, "relaton/bib/model/edition"
    autoload :Ext, "relaton/bib/model/ext"
    autoload :Extent, "relaton/bib/model/extent"
    autoload :Formattedref, "relaton/bib/model/formattedref"
    autoload :FullName, "relaton/bib/model/fullname"
    autoload :FullNameType, "relaton/bib/model/full_name_type"
    autoload :ICS, "relaton/bib/model/ics"
    autoload :Image, "relaton/bib/model/image"
    autoload :Item, "relaton/bib/model/item"
    autoload :ItemBase, "relaton/bib/model/item_base"
    autoload :ItemShared, "relaton/bib/model/item_shared"
    autoload :Keyword, "relaton/bib/model/keyword"
    autoload :Locality, "relaton/bib/model/locality"
    autoload :LocalityStack, "relaton/bib/model/locality_stack"
    # localized_string.rb defines three top-level constants:
    autoload :LocalizedString, "relaton/bib/model/localized_string"
    autoload :TypedLocalizedString, "relaton/bib/model/localized_string"
    autoload :LocalizedMarkedUpString, "relaton/bib/model/localized_string"
    autoload :LocalizedStringAttrs, "relaton/bib/model/localized_string_attrs"
    autoload :Logo, "relaton/bib/model/logo"
    autoload :Medium, "relaton/bib/model/medium"
    autoload :Note, "relaton/bib/model/note"
    autoload :Organization, "relaton/bib/model/organization"
    autoload :OrganizationType, "relaton/bib/model/organization_type"
    autoload :Person, "relaton/bib/model/person"
    autoload :Phone, "relaton/bib/model/phone"
    autoload :Place, "relaton/bib/model/place"
    # type/ is only a directory; these constants are top-level under Bib:
    autoload :PlainDate, "relaton/bib/model/type/plain_date"
    autoload :StringDate, "relaton/bib/model/type/string_date"
    autoload :Price, "relaton/bib/model/price"
    autoload :Relation, "relaton/bib/model/relation"
    autoload :Series, "relaton/bib/model/series"
    autoload :Size, "relaton/bib/model/size"
    autoload :SourceLocalityStack, "relaton/bib/model/source_locality_stack"
    autoload :Status, "relaton/bib/model/status"
    autoload :StructuredIdentifier, "relaton/bib/model/structured_identifier"
    autoload :Subdivision, "relaton/bib/model/subdivision"
    autoload :Title, "relaton/bib/model/title"
    autoload :Uri, "relaton/bib/model/uri"
    autoload :Validity, "relaton/bib/model/validity"
    autoload :Version, "relaton/bib/model/version"

    module Converter
      autoload :BibXml, "relaton/bib/converter/bibxml"
      autoload :Bibtex, "relaton/bib/converter/bibtex"
      autoload :Asciibib, "relaton/bib/converter/asciibib"
    end
  end
end
