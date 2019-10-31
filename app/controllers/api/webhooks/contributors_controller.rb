module API
  module Webhooks
    class ContributorsController < WebhooksController
      before_action :verify_github_webhook

      def create
        contribution = OpenSource::Contribution.new(payload_params)

        unless contribution.complete?
          head :no_content and return
        end

        contributor = Contributor.with_contribution(contribution)

        if contributor.save
          head :no_content
        else
          message = "Failed to save event with X-GitHub-Delivery: %s" % github_delivery
          render json: {error: message}, status: 500
        end
      end

      private

      def payload_params
        params.permit(:ref, sender: [:login, :id, :avatar_url], repository: [:default_branch])
      end
    end
  end
end
