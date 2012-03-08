module NetSuite
  module Actions
    class GetList
      include Support::Requests

      def initialize(klass, options = {})
        print klass
        @klass   = klass
        @options = options
      end

      private

      def request
        connection.request :platformMsgs, :getList do
          soap.namespaces['xmlns:platformMsgs'] = 'urn:messages_2011_2.platform.webservices.netsuite.com'
          soap.namespaces['xmlns:platformCore'] = 'urn:core_2011_2.platform.webservices.netsuite.com'
          soap.header = auth_header
          soap.body do |xml|
            @options[:list].each do |id|
              xml.platformMsgs :baseRef, :internalId => id, :type => 'inventoryType', "xsi:type" => "platformCore:RecordRef"
            end
          end
        end
      end

      def soap_type
        @klass.to_s.split('::').last.lower_camelcase
      end

      # <soap:Body>
      #   <platformMsgs:getList>
      #     <platformMsgs:baseRef internalId="983" type="customer" xsi:type="platformCore:RecordRef"/>
      #     <platformMsgs:baseRef internalId="-5" type="employee" xsi:type="platformCore:RecordRef"/>
      #   </platformMsgs:getList>
      # </soap:Body>
      def request_body
        b = Builder::XmlMarkup.new
        
        body = {
          'platformMsgs:getList' => [],
          :attributes! => {
            'platformMsgs:baseRef' => {
              'xsi:type'  => (@options[:custom] ? 'platformCore:CustomRecordRef' : 'platformCore:RecordRef')
            }
          }
        }
        
        @options[:list].each do |item|
          item_body = {
            'platformMsgs:baseRef' => {},
            :attributes! => {
              
            }
          }
          body['platformMsgs:getList'] << 
        end
        body[:attributes!]['platformMsgs:baseRef']['externalId'] = @options[:external_id] if @options[:external_id]
        body[:attributes!]['platformMsgs:baseRef']['internalId'] = @options[:internal_id] if @options[:internal_id]
        body[:attributes!]['platformMsgs:baseRef']['typeId']     = @options[:type_id]     if @options[:type_id]
        body[:attributes!]['platformMsgs:baseRef']['type']       = soap_type              unless @options[:custom]
        body
      end

      def success?
        @success ||= response_hash[:status][:@is_success] == 'true'
      end

      def response_body
        @response_body ||= response_hash[:record]
      end

      def response_hash
        @response_hash = @response[:get_response][:read_response]
      end

      module Support

        def self.included(base)
          base.extend(ClassMethods)
        end

        module ClassMethods

          def get(options = {})
            response = NetSuite::Actions::Get.call(self, options)
            if response.success?
             new(response.body)
            else
             raise RecordNotFound, "#{self} with OPTIONS=#{options.inspect} could not be found"
            end
          end

        end
      end

    end
  end
end
