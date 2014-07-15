require "muve/version"

# = Muve
# The muve gem provides a abstraction layer for the Muve resources which 
# include:
# * locations, the places of interest to be travelled to and fro
# * travellers, the wonderful creatures doing the travelling
# * movements, the appearances of a traveller at a location
#
# Although the gem is named *muve* which is short and sweet, the codename
# for the project is *Muvement* because is serves as a tool to help with 
# geolocation services.
#
# This gem is mostly for internal use and I expect it to be refactored numerous
# times to improve its usability and implementation.
module Muve
  require "muve/errors"
  require "muve/model"
  require "muve/location"
  require "muve/traveller"
  require "muve/movement"

  module Model
    def connection
      Model.connection
    end

    def self.connection(connection=nil)
      if(connection)
        @@conn = connection
      end
      @@conn
    end
  end

  def self.init(connection=nil)
    Model.connection(connection)
  end
end
