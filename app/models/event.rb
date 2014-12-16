class Event < ActiveRecord::Base
  belongs_to :stock
  belongs_to :user
  belongs_to :currency

  validates :user, presence: true
  validates :stock, presence: true
  validates :currency, presence: true
  validates :price, presence: true
  validates :quantity, presence: true
  validates :executed_on, presence: true

  enum action: [ :buy, :sell ]

  def self.total_capital_gain(year)
    sell
      .events_for_year(year)
      .map(&:capital_gain).sum.to_i
  end

  def self.events_for_year(year)
    where("strftime('%Y', executed_on) = ?", year.to_s)
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
    price * quantity * conversion_rate
  end

  def average_carrying
    return 0 if pool[:size] == 0

    ((pool[:value] / pool[:size])/conversion_rate).round(2)
  end

  def capital_gain
    if sell?
      cost = (quantity.to_f / pool[:size].to_f) * pool[:value]
      (total - cost).round(2)
    end
  end

  def conversion_rate
    currency.conversion_rate_to_default_currency(executed_on)
  end

  def this_and_previous_events
    Event.order(:executed_on).where("executed_on <= ?", executed_on)
  end
end
