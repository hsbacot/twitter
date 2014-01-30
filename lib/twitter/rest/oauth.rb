require 'twitter/request'
require 'twitter/rest/utils'
require 'twitter/token'

module Twitter
  module REST
    module OAuth
      include Twitter::REST::Utils

      # Allows a registered application to obtain an OAuth 2 Bearer Token, which can be used to make API requests
      # on an application's own behalf, without a user context.
      #
      # Only one bearer token may exist outstanding for an application, and repeated requests to this method
      # will yield the same already-existent token until it has been invalidated.
      #
      # @see https://dev.twitter.com/docs/api/1.1/post/oauth2/token
      # @rate_limited No
      # @authentication Required
      # @raise [Twitter::Error::Unauthorized] Error raised when supplied user credentials are not valid.
      # @return [Twitter::Token] The Bearer Token. token_type should be 'bearer'.
      # @param options [Hash] A customizable set of options.
      # @example Generate a Bearer Token
      #   client = Twitter::REST::Client.new(:consumer_key => "abc", :consumer_secret => 'def')
      #   bearer_token = client.token
      def token(options = {})
        options[:grant_type] ||= 'client_credentials'
        headers = {}
        headers[:accept]        = '*/*'
        headers[:authorization] = "Basic #{strict_encode64("#{@consumer_key}:#{@consumer_secret}")}"
        response = HTTP.with(headers).post('https://api.twitter.com/oauth2/token', :form => options)
        Twitter::Token.new(response.parse)
      end
      alias_method :bearer_token, :token

      # Allows a registered application to revoke an issued OAuth 2 Bearer Token by presenting its client credentials.
      #
      # @see https://dev.twitter.com/docs/api/1.1/post/oauth2/invalidate_token
      # @rate_limited No
      # @authentication Required
      # @raise [Twitter::Error::Unauthorized] Error raised when supplied user credentials are not valid.
      # @param access_token [String, Twitter::Token] The bearer token to revoke.
      # @param options [Hash] A customizable set of options.
      # @return [Twitter::Token] The invalidated token. token_type should be nil.
      def invalidate_token(access_token, options = {})
        access_token = access_token.access_token if access_token.is_a?(Twitter::Token)
        options[:access_token] = access_token
        perform_with_object(:post, '/oauth2/invalidate_token', options, Twitter::Token)
      end

      # Allows a registered application to revoke an issued OAuth 2 Bearer Token by presenting its client credentials.
      #
      # @see https://dev.twitter.com/docs/api/1.1/post/oauth2/invalidate_token
      # @rate_limited No
      # @authentication Required
      # @raise [Twitter::Error::Unauthorized] Error raised when supplied user credentials are not valid.
      # @return [String] The token string.
      def reverse_token
        uri = 'https://api.twitter.com/oauth/request_token'
        options = {:x_auth_mode => 'reverse_auth'}
        headers = {:authorization => oauth_auth_header(:post, uri, options).to_s}
        HTTP.with(headers).post(uri, :params => options).to_s
      end

    private

      # Base64.strict_encode64 is not available on Ruby 1.8.7
      def strict_encode64(str)
        Base64.encode64(str).gsub("\n", '')
      end
    end
  end
end
