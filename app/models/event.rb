class Event < ActiveRecord::Base
  belongs_to :stock
  belongs_to :user

  validates :stock, presence: true
  validates :price, presence: true
  validates :quantity, presence: true
  validates :executed_on, presence: true

  enum action: [ :buy, :sell ]

  def self.total_capital_gain(year)
    start_year = Date.parse("1-1-#{year}").at_beginning_of_year
    end_year   = Date.parse("1-1-#{year}").at_end_of_year

    Event.sell
      .where("executed_on >= ?", start_year)
      .where("executed_on <= ?", end_year)
      .map(&:capital_gain).sum.to_i
  end

  def pool
    @pool ||= begin
      size = 0
      value = 0

      this_and_previous_events.each do |event|
        if event.buy?
          value += event.total
          size += event.quantity
        else
          value -= ((event.quantity.to_f / size.to_f) * value).round(2)
          size -= event.quantity
        end
      end

      {
        size: size,
        value: value,
      }
    end
  end

  def total
    (price * quantity)
  end

  def average_carrying
    return 0 if pool[:size] == 0

    (pool[:value] / pool[:size]).round(2)
  end

  def capital_gain
    if sell?
      cost = (quantity.to_f / pool[:size].to_f) * pool[:value]
      (total - cost).round(2)
    end
  end

  def this_and_previous_events
    Event.order(:executed_on).where("executed_on <= ?", executed_on)
  end
end
