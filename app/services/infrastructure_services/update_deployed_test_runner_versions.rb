module InfrastructureServices
  class UpdateDeployedTestRunnerVersions
    include Mandate

    initialize_with :test_runner

    def call
      test_runner.versions.deploying.each do |version|
        next unless deployed_versions.include?(version.slug)

        # Only allow deploying -> deployed through this method
        TestRunnerVersion.where(id: version.id, status: :deploying).
                          update_all(status: :deployed)
      end
    end

    memoize
    def deployed_versions
      json = RestClient.get("#{orchestrator_url}/languages/#{test_runner.language_slug}/versions/deployed")
      JSON.parse(json)[:version_slugs]
    end
  end
end

