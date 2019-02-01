class AuthToken < ApplicationRecord
  scope :active, -> { where(active: true) }

  belongs_to :user

  before_create do
    self.token ||= SecureRandom.uuid
  end
end
