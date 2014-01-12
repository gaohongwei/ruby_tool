require 'oauth2'
module ApplicationHelper
end
module Oauth2API
    class Client

      OAUTH2_OPTIONS = {
          linkedin: {
            authorize_path: "/uas/oauth2/authorization",
            access_token_path: "/uas/oauth2/accessToken",
            api_host: "https://api.linkedin.com",
            auth_host: "https://www.linkedin.com",
            api_path: '/v1'
            },
          fb: {
            authorize_path: "/uas/oauth2/authorization",
            access_token_path: "/uas/oauth2/accessToken",
            api_host: "https://api.linkedin.com",
            auth_host: "https://www.linkedin.com",
            api_path: '/v1'
          }
      }


      DEFAULT_HEADERS = {
          'x-li-format' => 'json'
      }

      attr_reader :client_id, :client_secret, :access_token

      # The first two arguments must be your client_id, and client_secret.
      # The third option may either be an access_token or an options hash.
      def initialize(client_id=LinkedIn.client_id,
          client_secret=LinkedIn.client_secret,
          initial_access_token=nil,
          options={})
        @client_id     = client_id
        @client_secret = client_secret
        @oauth2_options=OAUTH2_OPTIONS[:linkedin]
        @api_path = @oauth2_options.delete(:api_path)
        if initial_access_token.is_a? Hash
          @client_options = initial_access_token
        else
          @client_options = options
          self.set_access_token initial_access_token
        end
      end

      def set_access_token(token, options={})
        options[:access_token] = token
        options[:mode] = :query
        options[:param_name] = "oauth2_access_token"
        @access_token = ::OAuth2::AccessToken.from_hash oauth2_client, options
      end

      def oauth2_client
        @oauth2_client ||= ::OAuth2::Client.new(@client_id,
                                                @client_secret,
                                                parse_oauth2_options)
      end
      def authorize_url(params={})
        # response_type param included by default by using the OAuth 2.0
        # auth_code strategy
        # client_id param included automatically by the OAuth 2.0 gem
        params[:state] ||= state
        params[:redirect_uri] ||= "http://localhost"
        oauth2_client.auth_code.authorize_url(params)
      rescue OAuth2::Error => e
        raise LinkedIn::Errors::UnauthorizedError.new(e.code), e.description
      end
      # Fetches the access_token given the auth_code fetched by
      # navigating to `authorize_url`
      # @param :redirect_uri - Where you want to redirect after you have
      # fetched the token.
      def request_access_token(code, params={})
        params[:redirect_uri] ||= "http://localhost"
        opts = {}
        opts[:mode] = :query
        opts[:param_name] = "oauth2_access_token"
        @access_token = oauth2_client.auth_code.get_token(code, params, opts)
      rescue OAuth2::Error => e
        raise LinkedIn::Errors::UnauthorizedError.new(e.code), e.description
      end

      def add_share(share)
        path = "/people/~/shares"
        defaults = {:visibility => {:code => "anyone"}}
        post(path, defaults.merge(share).to_json, "Content-Type" => "application/json")
      end
      def post(path, body='', options={})
        response = access_token.post("#{@api_path}#{path}", body: body, headers: DEFAULT_HEADERS.merge(options))
        raise_errors(response)
        response
      rescue OAuth2::Error => e
        raise LinkedIn::Errors::AccessDeniedError.new(e.code), e.description
      end
      private

      # The keys of this hash are designed to match the OAuth2
      # initialize spec.
      def parse_oauth2_options
        default = {site: @oauth2_options[:api_host],
            token_url: full_oauth_url_for(:access_token, :auth_host),
            authorize_url: full_oauth_url_for(:authorize, :auth_host)}
        return default.merge(@client_options)
      end
      def full_oauth_url_for(url_type, host_type)
        host = @oauth2_options[host_type]
        path = @oauth2_options["#{url_type}_path".to_sym]
        "#{host}#{path}"
      end
      def state
        @state ||= SecureRandom.hex(15)
      end
      def raise_errors(response)
        # Even if the json answer contains the HTTP status code, LinkedIn also sets this status
        # in the HTTP answer (thankfully).
        case response.status.to_i
          when 401
            data = Mash.from_json(response.body)
            raise LinkedIn::Errors::UnauthorizedError.new(data), "(#{data.status}): #{data.message}"
          when 400
            data = Mash.from_json(response.body)
            raise LinkedIn::Errors::GeneralError.new(data), "(#{data.status}): #{data.message}"
          when 403
            data = Mash.from_json(response.body)
            raise LinkedIn::Errors::AccessDeniedError.new(data), "(#{data.status}): #{data.message}"
          when 404
            raise LinkedIn::Errors::NotFoundError, "(#{response.status}): #{response.message}"
          when 500
            raise LinkedIn::Errors::InformLinkedInError, "LinkedIn had an internal error. Please let them know in the forum. (#{response.status}): #{response.message}"
          when 502..503
            raise LinkedIn::Errors::UnavailableError, "(#{response.status}): #{response.message}"
        end
      end
    end
end


module Oauth2API
  module Errors
    class LinkedInError < StandardError
      attr_reader :data
      def initialize(data)
        @data = data
        super
      end
    end

    class UnauthorizedError      < LinkedInError; end
    class GeneralError           < LinkedInError; end
    class AccessDeniedError      < LinkedInError; end

    class UnavailableError       < StandardError; end
    class InformLinkedInError    < StandardError; end
    class NotFoundError          < StandardError; end
  end
end


