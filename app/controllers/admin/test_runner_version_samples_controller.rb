class Admin::TestRunnerVersionSamplesController < AdminController
  before_action :set_test_runner_version

  def new
    @submission = User.system_user.submissions.where("submissions.uuid LIKE '#{@version.samples_uuid_prefix}%'").first
    @exercises = Track.find_by_slug!(@test_runner.language_slug).exercises.reorder(:title).map{|e|[e.title, e.id]}
    @previous_exercise_id = @submission.try(&:solution).try(&:exercise_id)
    (@previous_file_1, @previous_file_2) = @submission.try(&:files).to_a
  end

  def create
    JoinTrack.(User.system_user, Track.find_by_slug!(@test_runner.language_slug))
    @solution = CreateSolution.(User.system_user, Exercise.find(params[:exercise_id]))
    files = {}
    files[params[:file_1_filename]] = params[:file_1_code]
    files[params[:file_2_filename]] = params[:file_2_code] if params[:file_2_filename].present?

    uuid = SecureRandom.uuid.gsub('-', '')
    faux_uuid = "#{@version.samples_uuid_prefix}#{uuid}"
    SubmissionServices::Create.(faux_uuid, @solution, files, @version.slug)

    redirect_to action: :show, id: uuid
  end

  def show
    @submission = User.system_user.submissions.find_by_uuid!("#{@version.samples_uuid_prefix}#{params[:id]}")
  end

  def replay
    @submission = User.system_user.submissions.find_by_uuid!("#{@version.samples_uuid_prefix}#{params[:id]}")

    uuid = SecureRandom.uuid.gsub('-', '')
    faux_uuid = "#{@version.samples_uuid_prefix}#{uuid}"
    SubmissionServices::Create.(faux_uuid, @submission.solution, @submission.files, @version.slug)

    redirect_to action: :show, id: uuid
  end

  private
  def set_test_runner_version
    @test_runner = Infrastructure::TestRunner.find(params[:test_runner_id])
    @version = @test_runner.versions.find(params[:version_id])
  end
end
