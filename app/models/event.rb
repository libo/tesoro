class Event < ActiveRecord::Base
  belongs_to :stock
  belongs_to :user

  validates :stock, presence: true
  validates :price, presence: true
  validates :quantity, presence: true
  validates :executed_on, presence: true

  enum action: [ :buy, :sell ]

  def total
    (price * quantity)
  end

  def average_carrying
    acquisitions_qty = this_and_previous_acquisitions.sum(:quantity)

    return 0 if acquisitions_qty == 0

    this_and_previous_acquisitions.map(&:total).sum / acquisitions_qty
  end

  def capital_gain
    if sell?
      previous = 0

      previous_sells.each do |sell|
        previous += sell.quantity * sell.average_carrying
      end

      ((price - average_carrying) * quantity) - 80
    end
  end

  def this_and_previous_acquisitions
    Event.buy.order(:executed_on)
      .where("executed_on <= ?", executed_on)
  end

  def previous_sells
    Event.sell.order(:executed_on)
      .where("executed_on <= ?", executed_on)
      .where("id <> ?", id)
  end
end
