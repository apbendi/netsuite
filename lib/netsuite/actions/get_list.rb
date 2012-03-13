module NetSuite
  module Actions
    class GetList
      include Support::Requests
      
      attr_reader :errors
      
      def initialize(klass, options = [])
        @klass   = klass
        @options = options
        @errors  = []
      end
      
      public
      def errors_list
        @errors
        
      end

      private
      
      # <soap:Body>
      #   <platformMsgs:getList>
      #     <platformMsgs:baseRef internalId="983" type="customer" xsi:type="platformCore:RecordRef"/>
      #     <platformMsgs:baseRef internalId="-5" type="employee" xsi:type="platformCore:RecordRef"/>
      #   </platformMsgs:getList>
      # </soap:Body>

      def request
        # scope issues...
        options = @options
        
        connection.request :platformMsgs, :getList do
          soap.namespaces['xmlns:platformMsgs'] = "urn:messages_#{NetSuite::Configuration.api_version}.platform.webservices.netsuite.com"
          soap.namespaces['xmlns:platformCore'] = "urn:core_#{NetSuite::Configuration.api_version}.platform.webservices.netsuite.com"
          soap.header = auth_header
          soap.body = request_body
        end
      end

      def soap_type
        @klass.to_s.split('::').last.lower_camelcase
      end

      def success?
        @success = true
        
        response_hash.each do |response|
          unless response[:status][:@is_success] == 'true'
            @errors << {
              "type" => response[:status][:status_detail][:@type],
              "code" => response[:status][:status_detail][:code],
              "message" => response[:status][:status_detail][:message]
            }
            
            @success = false
          end
        end
        
        @success
      end
      
      def request_body
        # not sure if there is a way to do lists with the hash method of SOAP construction
        # needed to revert back to XMLBuilder
        
        buffer = ""
        xml = Builder::XmlMarkup.new :target => buffer
        @options.each do |id|
          xml.platformMsgs :baseRef, :internalId => id, :type => 'inventoryItem', "xsi:type" => "platformCore:RecordRef"
        end
        buffer
      end

      def response_body
        @response_body ||= response_hash
      end

      def response_hash
        @response_hash = @response[:get_list_response][:read_response_list][:read_response]
      end

      module Support

        def self.included(base)
          base.extend(ClassMethods)
        end

        module ClassMethods

          def getList(options = [])
            response = NetSuite::Actions::GetList.call(self, options)
            if response.success?
              response_list = []
              response.body.each do |list_response|
                response_list << new(list_response[:record])
              end
              
              response_list
            else
             raise RecordNotFound, "#{self} with OPTIONS=#{options.inspect} could not be found. Errors: #{response.errors}"
            end
          end

        end
      end

    end
  end
end
