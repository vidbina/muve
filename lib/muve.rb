require "muve/version"

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

    def self.connection
      @@conn ||= Object.new
    end
  end

  def self.init
    Model.connection
  end
end
