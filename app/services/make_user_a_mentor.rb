class MakeUserAMentor
  include Mandate

  initialize_with :user, :track_id

  def call
    make_mentor
    create_track_mentorship
    invite_to_slack
  end

  def make_mentor
    user.create_mentor_profile!
  end

  def create_track_mentorship
    user.track_mentorships.create(track_id: track_id)
  end

  def invite_to_slack
    data = {
      email: user.email,
      token: Rails.application.secrets.slack_api_token,
      set_active: 'true'
    }
    RestClient.post(slack_api_invite_url, data)
  rescue SocketError => e
    raise e if Rails.env.production?
  end

  def slack_api_invite_url
    Rails.env.production?? "https://exercism-mentors.slack.com/api/users.admin.invite" :
                           "https://dev.null.exercism.io"
  end
end
