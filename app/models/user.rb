class User < ApplicationRecord
  has_secure_password

  has_many :friendships_as_user,   class_name: "Friendship", foreign_key: :user_id,   dependent: :destroy
  has_many :friendships_as_friend, class_name: "Friendship", foreign_key: :friend_id, dependent: :destroy
  has_many :invites, dependent: :destroy
  has_many :sent_hoots,     class_name: "Hoot", foreign_key: :sender_id,   dependent: :destroy
  has_many :received_hoots, class_name: "Hoot", foreign_key: :receiver_id, dependent: :destroy

  validates :email,    presence: true, uniqueness: { case_sensitive: false },
                       format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :username, presence: true, uniqueness: { case_sensitive: false },
                       length: { in: 3..20 },
                       format: { with: /\A[a-z0-9_]+\z/i, message: "only allows letters, numbers, and underscores" }
  validates :password, length: { minimum: 6 }, if: -> { new_record? || password.present? }

  normalizes :email,    with: ->(e) { e.strip.downcase }
  normalizes :username, with: ->(u) { u.strip.downcase }

  def friendships
    Friendship.where("user_id = :id OR friend_id = :id", id: id)
  end

  def friends
    friend_ids = friendships.pluck(:user_id, :friend_id).flatten.uniq - [id]
    User.where(id: friend_ids)
  end
end
