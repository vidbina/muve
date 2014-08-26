module Muve
  module Error
    class StandardError < StandardError; end
  
    class IncompleteImplementation < StandardError; end
  
    class InvalidAttribute < StandardError; end
  
    class InvalidQuery < StandardError; end
  
    class NotConfigured < StandardError; end
  
    class NotFound < StandardError; end
  
    class ValidationError < StandardError; end
  
    class SaveError < StandardError; end
  end
end
