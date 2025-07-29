class Micropost < ApplicationRecord
  MICROPOST_PERMITTED = %i(content image).freeze
  MAX_IMAGE_SIZE = 5.megabytes
  MEGABYTE_IN_BYTES = 1.megabyte
  IMAGE_DISPLAY_SIZE = [500, 500].freeze

  belongs_to :user
  has_one_attached :image

  validates :content, presence: true, length: {maximum: Settings.digit_140}
  validates :image, content_type: {in: %w(image/jpeg image/gif image/png),
                                   message: :invalid_image_type},
                    size: {less_than: MAX_IMAGE_SIZE,
                           message: :image_too_large}

  scope :recent, ->{order(created_at: :desc)}

  has_one_attached :image do |attachable|
    attachable.variant :display, resize_to_limit: IMAGE_DISPLAY_SIZE
  end
end
