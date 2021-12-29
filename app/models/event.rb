class Event < ApplicationRecord
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

  before_validation :set_sort_column

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

  def pool
    Pool.for_event(self)
  end

  def total
    price * quantity * conversion_rate
  end

  def average_carrying
    return 0 if pool.empty?

    ((pool.value / pool.size)/conversion_rate).round(2)
  end

  def capital_gain
    if sell?
      return 0 unless previous_event.present?

      cost = (quantity.to_f / previous_event.pool.size) * previous_event.pool.value

      (total - cost).round(2)
    end
  end

  def conversion_rate
    currency.conversion_rate_to_default_currency(executed_on)
  end

  def previous_event
    @previous_event ||= Event.order(:sort_column)
      .where("sort_column < ?", sort_column)
      .where(user_id: user_id)
      .where(stock_id: stock_id)
      .last
  end

  def this_and_previous_events
    @this_and_previous_events ||= Event.order(:sort_column)
      .where("sort_column <= ?", sort_column)
      .where(user_id: user_id)
      .where(stock_id: stock_id)
      .includes(:currency)
  end

  def set_sort_column
    # Ordered so that buys are before sales.
    self.sort_column = "#{executed_on.iso8601}/#{self.class.actions[action]}/#{Time.now.to_f}"
  end
end
