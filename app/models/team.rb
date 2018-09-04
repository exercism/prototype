class Team < ApplicationRecord
  extend FriendlyId
  friendly_id :slug_candidates, use: :slugged

  def slug_candidates
    [
      :name,
      [:name, -> { SecureRandom.uuid.split("-").first }],
    ]
  end

  has_many :solutions, class_name: "TeamSolution"
  has_many :iterations, through: :solutions

  has_many :invitations, class_name: "TeamInvitation"
  has_many :memberships, class_name: "TeamMembership"
  has_many :members, through: :memberships, source: :user
  #has_many :admins,
  #  -> { where(team_memberships: { admin: true }) },
  #  through: :memberships,
  #  source: :user

  has_secure_token :token

  def admin?(user)
    memberships.where(admin: true).where(user_id: user.id).exists?
  end
end
