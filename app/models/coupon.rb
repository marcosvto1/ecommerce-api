class Coupon < ApplicationRecord
  class InvalidUse < StandardError; end

  include Paginatable
  include LikeSearchable

  validates :code, presence: true, uniqueness: { case_sensitive: false }
  validates :status, presence: true
  validates :due_date, presence: true, future_date: true
  validates :discount_value, presence: true, numericality: { greater_than: 0 }

  enum status: { active: 1, inactive: 2 }

  def validate_use!
    raise InvalidUse unless self.active? && self.due_date >= Time.now
    true
  end
end
