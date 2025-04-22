module Relaton
  module Bib
    module Parser
      class RfcOrganization
        ORGNAMES = {
          "IEEE" => "Institute of Electrical and Electronics Engineers",
          "W3C" => "World Wide Web Consortium",
          "3GPP" => "3rd Generation Partnership Project",
        }.freeze

        include RfcContacts

        def self.transform(author)
          org = author.organization
          return if org.nil? || org.content.empty?

          new(author).transform
        end

        def transform
          name = ORGNAMES[@author.organization.content] || @author.organization.content
          orgname = TypedLocalizedString.new(content: name, language: "en")
          abbrev = LocalizedString.new(content: @author.organization.abbrev, language: "en")
          Organization.new(
            name: [orgname], abbreviation: abbrev, address: address, phone: phone, email: email, uri: uri,
          )
        end
      end
    end
  end
end
