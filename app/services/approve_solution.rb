class ApproveSolution
  include Mandate
  include HTMLGenerationHelpers

  attr_reader :solution, :mentor
  def initialize(solution, mentor)
    @solution = solution
    @mentor = mentor
  end

  def call
    return false unless mentor_may_approve?

    solution.update(approved_by: mentor)

    mentorship = CreatesSolutionMentorship.create(solution, mentor)
    solution.update!(last_updated_by_mentor_at: Time.current)
    mentorship.update!(requires_action: false)
    notify_solution_user
  end

  private

  def notify_solution_user
    CreatesNotification.create!(
      solution.user,
      :solution_approved,
      "#{strong mentor.handle} has approved your solution to #{strong solution.exercise.title} on the #{strong solution.exercise.track.title} track.",
      routes.my_solution_url(solution),
      trigger: mentor,
      about: solution
    )

    DeliversEmail.deliver!(
      solution.user,
      :solution_approved,
      solution
    )
  end

  def mentor_may_approve?
    mentor.mentoring_track?(solution.exercise.track)
  end
end
