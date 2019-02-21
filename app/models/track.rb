class Track < ApplicationRecord
  extend FriendlyId

  friendly_id :slug, use: [:history]

  has_many :testimonials
  has_many :user_tracks
  has_many :exercises, -> { order position: :asc, title: :asc }
  has_many :solutions, through: :exercises
  has_many :iterations, through: :solutions
  has_many :mentorships, class_name: "TrackMentorship"

  has_many :maintainers

  scope :active, ->{ where(active: true) }

  delegate :head, to: :repo

  [:bordered_green_icon_url,
   :bordered_turquoise_icon_url,
   :hex_green_icon_url,
   :hex_turquoise_icon_url,
   :hex_white_icon_url,
   :hex_green_icon_url,
  ].each do |icon|
    define_method icon do
      super() || "https://assets.exercism.io/tracks/default-#{icon.to_s.gsub(/_icon_url/,'').dasherize}.png"
    end
  end

  def introduction
    i = super
    i.present?? i : "TODO: The maintainers have not provided an introduction for this track."
  end

  def about
    repo.about.present?? ParseMarkdown.(repo.about) : nil
  end

  def repo
    Git::ExercismRepo.new(repo_url)
  end

  def num_active_mentors
    active_solution_mentorship_user_ids.count
  end

  def active_mentors
    User.where(id: active_solution_mentorship_user_ids)
  end

  private
  def active_solution_mentorship_user_ids
    SolutionMentorship.
      joins(solution: :exercise).
      where('exercises.track_id': id).
      where("solution_mentorships.created_at > ?", Time.current - Exercism::MENTOR_ACTIVE_THRESHOLD).
      select(:user_id).distinct
  end
end
