module NetSuite
  module Actions
    class GetList
      include Support::Requests
      
      attr_reader :errors
      attr_reader :safe_list
      
      def initialize(klass, options = [])
        @klass   = klass
        @options = options
        
        @errors  = []
        @safe_list = []
      end

      private
      
      # <soap:Body>
      #   <platformMsgs:getList>
      #     <platformMsgs:baseRef internalId="983" type="customer" xsi:type="platformCore:RecordRef"/>
      #     <platformMsgs:baseRef internalId="-5" type="employee" xsi:type="platformCore:RecordRef"/>
      #   </platformMsgs:getList>
      # </soap:Body>

      def request
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
        
        # as far as I can tell the order of the requests & responses is maintained
        # therefore, matching up the index of the response to the index of the request should work in giving us an internal ID of the problem record
        # this will enable us to grab some of the responses and error report problem records or run them through a seperate request
        
        response_hash.each_index do |index|
          response = response_hash[index]
          
          unless response[:status][:@is_success] == 'true'
            @errors << {
              :type => response[:status][:status_detail][:@type],
              :code => response[:status][:status_detail][:code],
              :message => response[:status][:status_detail][:message],
              :internal_id => @options[index]
            }
            
            @success = false
          else
            @safe_list << response
          end
        end
        
        @success
      end
      
      def request_body
        # not sure if there is a way to do lists with the hash method of SOAP construction
        # needed to revert back to XMLBuilder
        
        buffer = ""
        record_type = soap_type
        xml = Builder::XmlMarkup.new :target => buffer
        @options.each do |id|
          xml.platformMsgs :baseRef, :internalId => id, :type => record_type, "xsi:type" => "platformCore:RecordRef"
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
            
            all_success = response.success?
            response_list = []
            
            response.safe_list.each do |list_response|
              response_list << new(list_response[:record])
            end
            
            if all_success
              response_list
            else
             raise RecordNotFound.new(response.errors, response_list), "#{self} with OPTIONS=#{options.inspect} could not be found. Errors: #{response.errors}"
            end
          end

        end
      end

    end
  end
end
