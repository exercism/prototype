class Git::Exercise
  attr_reader :track, :title, :git_slug, :git_sha

  delegate :tests_info, to: :exercise_reader

  def initialize(exercise, git_slug, git_sha)
    @track = exercise.track
    @title = exercise.title
    @git_slug = git_slug
    @git_sha = git_sha
  end

  def instructions
    lines = exercise_reader.readme.split("\n")
    lines.shift if /^#\s*#{@title}\s*$/.match? lines.first
    ParseMarkdown.(lines.join("\n"))
  end

  def test_suite
    exercise_reader.tests
  end

  def solution_files
    exercise_reader.solution_files
  end

  def exercise_config
    exercise_reader.exercise_config
  end

  private

  def exercise_reader
    @repo_exercise ||= repo.exercise(git_slug, git_sha)
  end

  def repo_url
    track.repo_url
  end

  def repo
    Git::ExercismRepo.new(repo_url)
  end
end
