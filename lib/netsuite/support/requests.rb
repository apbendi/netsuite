module NetSuite
  module Support
    module Requests

      def self.included(base)
        base.send(:extend, ClassMethods)
      end

      module ClassMethods

        def call(*args)
          new(*args).call
        end

      end

      def call
        @response = request
        build_response
      end

      private

      def request
        raise NotImplementedError, 'Please implement a #request method'
      end

      def connection
        Configuration.connection
      end

      def auth_header
        Configuration.auth_header
      end

      def build_response
        # TODO: when searching is supported the :safe_list should be used for those requests as well
        if self.class == NetSuite::Actions::GetList
          Response.new(:success => success?, :body => response_body, :errors => errors, :safe_list => safe_list)
        else
          Response.new(:success => success?, :body => response_body)  
        end
      end

      def success?
        raise NotImplementedError, 'Please implement a #success? method'
      end

      def response_body
        raise NotImplementedError, 'Please implement a #response_body method'
      end
      
      def errors
        # don't require implementation at this point...
        # raise NotImplementedError, 'Please implement a #errors method'
        []
      end

      def safe_list
        []
      end
    end
  end
end
