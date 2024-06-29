module Relaton
  module Model
    class Contact < Shale::Mapper
      attribute :address, Shale::Type::String
      attribute :phone, Shale::Type::String
      attribute :email, Shale::Type::String
      attribute :uri, Uri
    end
  end
end
