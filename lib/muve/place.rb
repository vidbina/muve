module Muve
  class Place
    include Model

    with_fields :name, :location

    def valid?
      return false unless name
      return false unless location.kind_of?(Muve::Location) && location.valid?
      true
    end
  end
end
