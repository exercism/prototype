module InfrastructureServices
  class UpdateBuiltTestRunnerVersions
    include Mandate

    initialize_with :test_runner

    def call
      test_runner.versions.building.each do |version|
        next unless image_tags.include?(version.slug)

        # Only allow building -> build through this method
        TestRunnerVersion.where(id: version.id, status: :building).
                          update_all(status: :built) 
      end
    end

    memoize
    def image_tags
      resp_name = "#{test_runner.language_slug}-test-runner"

      client.list_images({
        repository_name: resp_name,
        max_results: 1000
      }).image_ids.
         map(&:image_tag).
         select{|tag| tag.starts_with?(/git-/)}.
         map{|tag|tag.gsub(/git-/, '')}
    end

    memoize
    def client
      Aws::ECR::Client.new(
       access_key_id: Rails.application.secrets.aws_access_key_id,
       secret_access_key: Rails.application.secrets.aws_secret_access_key,
       region: Rails.application.secrets.aws_region
     )
    end
  end
end
