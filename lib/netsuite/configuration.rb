module NetSuite
  module Configuration
    extend self

    def reset!
      attributes.clear
    end

    def attributes
      @attributes ||= {}
    end

    def connection
      attributes[:connection] ||= Savon::Client.new(self.wsdl)
    end
    
    def api_version(version = nil)
      if version
        self.api_version = version
      else
        attributes[:api_version] ||= '2012_1'
      end
    end

    def api_version=(version)
      attributes[:api_version] = version
    end

    def is_prod?(is_prod = nil)
      if(is_prod)
        self.is_prod = is_prod
      else
        attributes[:is_prod] ||= false
      end
    end

    def is_prod=(is_prod)
      attributes[:is_prod] = is_prod
    end

    def wsdl=(wsdl)
      attributes[:wsdl] = wsdl
    end

    def wsdl(wsdl = nil)
      if wsdl
        self.wsdl = wsdl
      else
        if self.is_prod?
          attributes[:wsdl] ||= "https://webservices.netsuite.com/wsdl/v#{api_version}_0/netsuite.wsdl"
        else
          attributes[:wsdl] ||= "https://webservices.sandbox.netsuite.com/wsdl/v#{api_version}_0/netsuite.wsdl"
        end
      end
    end

    def auth_header
      attributes[:auth_header] ||= {
        'platformMsgs:passport' => {
          'platformCore:email'    => email,
          'platformCore:password' => password,
          'platformCore:account'  => account.to_s,
          'platformCore:role'     => role.to_record,
          :attributes! => {
            'platformCore:role' => role.attributes!
          }
        }
      }
    end
    
    def role=(role)
      attributes[:role] = NetSuite::Records::RecordRef.new(:internal_id => role, :type => 'role')
    end
    
    def role(role = nil)
      if role
        self.role = role
      else 
        attributes[:role] ||= NetSuite::Records::RecordRef.new(:internal_id => '3', :type => 'role')
      end
    end

    def email=(email)
      attributes[:email] = email
    end

    def email(email = nil)
      if email
        self.email = email
      else
        attributes[:email] ||
        raise(ConfigurationError,
          '#email is a required configuration value. Please set it by calling NetSuite::Configuration.email = "me@example.com"')
      end
    end

    def password=(password)
      attributes[:password] = password
    end

    def password(password = nil)
      if password
        self.password = password
      else
        attributes[:password] ||
        raise(ConfigurationError,
          '#password is a required configuration value. Please set it by calling NetSuite::Configuration.password = "my_pass"')
      end
    end

    def account=(account)
      attributes[:account] = account
    end

    def account(account = nil)
      if account
        self.account = account
      else
        attributes[:account] ||
        raise(ConfigurationError,
          '#account is a required configuration value. Please set it by calling NetSuite::Configuration.account = 1234')
      end
    end

  end
end
