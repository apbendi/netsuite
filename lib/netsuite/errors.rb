module NetSuite
  class RecordNotFound < StandardError
    attr_accessor :errors
    attr_accessor :records
    
    def initialize(errors = nil, records = nil)
      @errors = errors || []
      @records = records || []
    end
  end
  
  class InitializationError < StandardError; end
  class ConfigurationError < StandardError; end
end
