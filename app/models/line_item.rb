class LineItem < ApplicationRecord
  belongs_to :order
  belongs_to :product

  attr_reader :total

  validates :quantity, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :payed_price, presence: true, numericality: { greater_than: 0 }

  def total
    self.payed_price * self.quantity
  end
end

