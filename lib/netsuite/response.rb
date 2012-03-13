module NetSuite
  class Response
    attr_accessor :body
    attr_reader :errors, :safe_list

    def initialize(attributes = {})
      @success = attributes[:success]
      @body    = attributes[:body]
      @errors  = attributes[:errors]
      @safe_list = attributes[:safe_list]
    end

    def success!
      @success = true
    end

    def success?
      @success
    end

  end
end
