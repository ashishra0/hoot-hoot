class Friendship < ApplicationRecord
  belongs_to :user
  belongs_to :friend, class_name: "User"

  has_many :hoots, dependent: :destroy

  before_validation :normalize_ids

  validates :user_id, uniqueness: { scope: :friend_id }
  validate :not_self_friendship

  def self.between(user_a, user_b)
    low, high = [ user_a.id, user_b.id ].sort
    find_by(user_id: low, friend_id: high)
  end

  def partner_of(user)
    user.id == user_id ? friend : self.user
  end

  def role_of(user)
    user.id == user_id ? :user : :friend
  end

  def hooted_today?(user)
    role_of(user) == :user ? user_hooted_today : friend_hooted_today
  end

  private

  def normalize_ids
    if user_id.present? && friend_id.present? && user_id > friend_id
      self.user_id, self.friend_id = friend_id, user_id
    end
  end

  def not_self_friendship
    errors.add(:friend_id, "can't befriend yourself") if user_id == friend_id
  end
end
