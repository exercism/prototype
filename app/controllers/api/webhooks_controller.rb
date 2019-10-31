require "open_source"

module API
  class WebhooksController < ApplicationController
    protect_from_forgery with: :null_session

    protected
    def verify_github_webhook
      payload = request.body.read
      signature = 'sha1=' + OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha1'), secret, payload)
      if !Rack::Utils.secure_compare(signature, github_signature)
        render json: {error: 'invalid signature - delivery: %s' % github_delivery}, status: 500
      end
    end

    def secret
      Rails.application.secrets.github_webhook_secret
    end

    def github_signature
      request.env['HTTP_X_HUB_SIGNATURE']
    end

    def github_delivery
      request.headers['HTTP_X_GITHUB_DELIVERY']
    end
  end
end
