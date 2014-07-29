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
  require "muve/helpers"
  require "muve/model"
  require "muve/store"
  require "muve/location"
  require "muve/traveller"
  require "muve/movement"

  module Model
    # Connection to the datastore
    def connection
      Model.connection
    end
    
    # Database instance for the model
    def database
      Model.database
    end

    # Set the connection to the datastore
    def self.connection=connection
      (@@conn = connection) if (connection)
    end

    def self.database=database
      (@@db = database) if (database)
    end

    # Connection to the datastore
    def self.connection
      begin
      @@conn
      rescue => e
        raise MuveNotConfigured, "the connection has not been defined"
      end
    end

    # Database instance to be used by the adaptor
    def self.database
      begin
        @@db
      rescue => e
        raise MuveNotConfigured, "the database has not been defined"
      end
    end
  end

  # Initialize Muve with an optional connection to the datastore.
  # This could be a MongoDB or PostgreSQL connection for instance. Besides a 
  # connection, an adaptor will be needed to actually handle the interaction 
  # between the models and the datastore through the given connection.
  def self.init(connection=nil, database=nil)
    Model.connection =connection
    Model.database = database # can't automatically infer the db as this may differ among adaptors
  end
end
