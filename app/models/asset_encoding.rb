# An asset encoding with type of video, audio, or image, width, height and duration
class AssetEncoding < ActiveRecord::Base
  belongs_to :asset
  validates :asset, presence: true
  validates :uri, presence: true
  validates :type, inclusion: { in: %w(audio image video) }
end
