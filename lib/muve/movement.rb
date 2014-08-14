module Muve
  class Movement
    include Model
  
    with_fields :traveller, :location, :time
  
    def valid?
      assocs.each do |assoc|
        return false unless !assoc.nil? && assoc.valid?
      end
      fields.each do |field|
        return false unless time
      end
      true
    end
  
    private
    def assocs
      [
        @traveller,
        @location
      ]
    end
  end
end
