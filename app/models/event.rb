class Event < ApplicationRecord
  belongs_to :stock
  belongs_to :user
  belongs_to :currency

  validates :user, presence: true
  validates :stock, presence: true
  validates :currency, presence: true
  validates :price, presence: true # Use this as the price real price at purchase
  validates :quantity, presence: true
  validates :executed_on, presence: true

  enum action: [ :buy, :sell ]

  def self.total_capital_gain(year)
    sell
      .events_for_year(year)
      .map(&:capital_gain).sum.to_i
  end

  def self.events_for_year(year)
    day = Date.new(year)
    year_range = (day...day + 1.year)

    where(executed_on: year_range)
  end

  def self.total_discount(year)
    total_discount = buy
      .events_for_year(year)
      .sum(&:total_discounted)
    total_price = buy
      .events_for_year(year)
      .sum(&:total)

    return 0 if total_discount == 0

    (total_price - total_discount).round(2)
  end

  def pool
    cache_key = Digest::SHA1.hexdigest(this_and_previous_events.map(&:cache_key).join('/'))

    Rails.cache.fetch("event_pool/#{cache_key}", expires_in: 12.hours) do
      size = 0
      value = 0

      this_and_previous_events.each do |event|
        if event.buy?
          value += event.total
          size += event.quantity
        else
          next if size == 0
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

  def total_discounted
    return 0 unless include_discount
    price_discounted * quantity * conversion_rate
  end

  def average_carrying
    return 0 if pool[:size] == 0

    ((pool[:value] / pool[:size])/conversion_rate).round(2)
  end

  def capital_gain
    if sell?
      previous_event = this_and_previous_events[-2]
      return 0 unless previous_event.present?

      cost = (quantity.to_f / previous_event.pool[:size]) * previous_event.pool[:value]

      (total - cost).round(2)
    end
  end

  def discount
    if buy?
      ((price - price_discounted) * quantity * conversion_rate).round(2)
    end
  end

  def conversion_rate
    currency.conversion_rate_to_default_currency(executed_on)
  end

  def this_and_previous_events
    # ordered so that buy are before sales.
    Event.order(:executed_on, :action)
      .where("executed_on <= ?", executed_on)
      .where(user: user)
      .where(stock: stock)
  end
end
