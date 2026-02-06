class Invite < ApplicationRecord
  belongs_to :user
  belongs_to :claimed_by, class_name: "User", optional: true

  before_create :generate_token, :set_expiry

  scope :active, -> { where(claimed_at: nil).where("expires_at > ?", Time.current) }

  def expired?
    expires_at < Time.current
  end

  def claimed?
    claimed_at.present?
  end

  private

  def generate_token
    self.token = SecureRandom.alphanumeric(12)
  end

  def set_expiry
    self.expires_at = 7.days.from_now
  end
end
