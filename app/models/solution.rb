class Solution < ApplicationRecord
  include SolutionBase

  belongs_to :approved_by, class_name: "User", optional: true

  has_many :iterations, dependent: :destroy, as: :solution
  has_many :discussion_posts, through: :iterations

  has_many :mentorships, class_name: "SolutionMentorship", dependent: :destroy
  has_many :ignored_mentorships, class_name: "IgnoredSolutionMentorship", dependent: :destroy
  has_many :solution_locks, dependent: :destroy
  has_many :mentors, through: :mentorships, source: :user

  has_many :stars, class_name: "SolutionStar", dependent: :destroy
  has_many :comments, class_name: "SolutionComment", dependent: :destroy

  has_many :notifications, as: :about, dependent: :destroy

  delegate :auto_approve?, to: :exercise
  delegate :max_mentoring_slots,
    :mentoring_slots_remaining,
    to: :user_track,
    prefix: :track

  scope :core, -> { joins(:exercise).merge(Exercise.core) }
  scope :side, -> { joins(:exercise).merge(Exercise.side) }

  scope :approved, -> { where.not(approved_by_id: nil) }
  scope :not_approved, -> { where(approved_by_id: nil) }

  scope :completed, -> { where.not(completed_at: nil) }
  scope :not_completed, -> { where(completed_at: nil) }

  scope :published, -> { where.not(published_at: nil) }
  scope :on_profile, -> { where(show_on_profile: true) }

  scope :legacy, -> { where("solutions.created_at < ?", Exercism::V2_MIGRATED_AT) }
  scope :not_legacy, -> { where("solutions.created_at >= ?", Exercism::V2_MIGRATED_AT) }

  scope :started, -> {
    where("EXISTS(SELECT TRUE FROM iterations WHERE iterations.solution_id = solutions.id)
           OR
           downloaded_at IS NOT NULL")
  }

  scope :not_started, -> {
    where("NOT EXISTS(SELECT TRUE FROM iterations WHERE iterations.solution_id = solutions.id)").
    where(downloaded_at: nil)
  }

  scope :submitted, -> {
    where("EXISTS(SELECT TRUE FROM iterations WHERE iterations.solution_id = solutions.id)")
  }

  scope :not_submitted, -> {
    where("NOT EXISTS(SELECT TRUE FROM iterations WHERE iterations.solution_id = solutions.id)")
  }

  scope :has_a_mentor, -> {
     where("EXISTS(SELECT TRUE FROM solution_mentorships WHERE solution_mentorships.solution_id = solutions.id)")
  }

  def exercise_is_core?
    exercise.core?
  end

  def display_published_at
    published_at == Exercism::V2_MIGRATED_AT ? created_at : published_at
  end

  def track_in_mentored_mode?
    track_in_independent_mode === false
  end

  def track_accepting_new_students?
    track.accepting_new_students?
  end

  def mentor_download_command
    "exercism download --uuid=#{uuid}"
  end

  def team_solution?
    false
  end

  def legacy?
    created_at < Exercism::V2_MIGRATED_AT
  end

  def last_updated_legacy?
    last_updated_by_user_at && last_updated_by_user_at <= Exercism::V2_MIGRATED_AT
  end

  def approved?
    !!approved_by
  end

  def approved_by_system?
    approved_by == User.system_user
  end

  def in_progress?
    downloaded? || iterations.size > 0
  end

  def published?
    !!published_at
  end

  def completed?
    !!completed_at
  end

  def mentoring_requested?
    !!mentoring_requested_at
  end

  def active_mentors
    mentorships.active.includes(:user).map(&:user)
  end

  def mentor_discussion_posts
    discussion_posts.where.not(user_id: user_id)
  end

  def user_track
    UserTrack.find_by(user_id: user_id, track_id: exercise.track_id)
  end

  def use_auto_analysis?
    return false if approved?
    return false if mentorships.present?
    return false if solution_locks.where.not(user_id: User::SYSTEM_USER_ID).present?

    true
  end
end
