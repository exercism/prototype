module API
  module Webhooks
    class RepoUpdatesController < WebhooksController
      before_action :verify_github_webhook

      MASTER_REF = "refs/heads/master"

      def create
        return unless pushed_to_master?

        repo_update = RepoUpdate.new(slug: slug)

        render json: {} if repo_update.save
      end

      private

      def payload_params
        params.permit(:ref, { repository: :name })
      end

      def pushed_to_master?
        payload_params[:ref].eql? MASTER_REF
      end

      def slug
        payload_params[:repository][:name]
      end
    end
  end
end
