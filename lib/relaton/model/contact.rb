module Relaton
  module Model
    class Contact < Lutaml::Model::Serializable
      attribute :address, Lutaml::Model::Type::String
      attribute :phone, Lutaml::Model::Type::String
      attribute :email, Lutaml::Model::Type::String
      attribute :uri, Uri
    end
  end
end
