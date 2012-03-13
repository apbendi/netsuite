module NetSuite
  class Response
    attr_accessor :body
    attr_reader :errors

    def initialize(attributes = {})
      @success = attributes[:success]
      @body    = attributes[:body]
      @errors  = attributes[:errors]
    end

    def success!
      @success = true
    end

    def success?
      @success
    end

  end
end
