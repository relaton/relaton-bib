module Relaton
  module Bib
    module Parser
      class RfcPerson
        include RfcContacts

        def self.transform(author)
          return unless author.fullname || author.surname

          new(author).transform
        end

        def transform
          Person.new(
            name: name, affiliation: affiliation, address: address, phone: phone, email: email, uri: uri,
          )
        end

        def name
          FullName.new(
            completename: LocalizedString.new(content: @author.fullname, language: "en"),
            formatted_initials: initials,
            surname: LocalizedString.new(content: @author.surname, language: "en"),
          )
        end

        def initials
          return unless @author.initials

          LocalizedString.new(content: @author.initials, language: "en")
        end

        def affiliation
          org = RfcOrganization.transform(@author)
          return [] unless org

          [Affiliation.new(organization: org)]
        end
      end
    end
  end
end
