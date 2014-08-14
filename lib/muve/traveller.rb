module Muve
  class Traveller
    include Model

    with_fields :name
  
    def valid?
      !name.nil? && !name.empty?
    end
  end
end
