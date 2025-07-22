class User < ApplicationRecord
  has_secure_password

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

  USER_PERMITTED = %i(
    name email password
    password_confirmation birthday gender
  ).freeze

  enum gender: {female: 0, male: 1, other: 2}

  validates :name,
            presence: true,
            length: {maximum: Settings.user.max_name_length}
  validates :email,
            presence: true,
            length: {maximum: Settings.user.max_email_length},
            format: {with: VALID_EMAIL_REGEX},
            uniqueness: {case_sensitive: false}
  validates :birthday, presence: true
  validates :gender, presence: true

  validate :birthday_within_100_years

  private

  def birthday_within_100_years
    return if birthday.blank? || !birthday.is_a?(Date)

    current_date = Time.zone.today
    hundred_years_ago = current_date.prev_year(Settings.user.hundred_years)

    if birthday < hundred_years_ago
      errors.add(:birthday, :too_old)
    elsif birthday > current_date
      errors.add(:birthday, :in_future)
    end
  end
end
