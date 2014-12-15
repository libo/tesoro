class Event < ActiveRecord::Base
  belongs_to :stock
  belongs_to :user

  validates :stock, presence: true
  validates :price, presence: true
  validates :quantity, presence: true
  validates :executed_on, presence: true

  enum action: [ :buy, :sell ]

  def pool
    @pool ||= begin
      rows = []

      this_and_previous_events.each do |event|
        if event.buy?
          rows << { size: event.quantity, value: event.total }
        else
          size_so_far = rows.map{ |v| v[:size]}.sum
          value_so_far = rows.map{ |v| v[:value]}.sum

          value = ((event.quantity.to_f / size_so_far.to_f) * value_so_far).round(2)
          rows << { size: -event.quantity, value: -value }
        end
      end

      {
        size: rows.map{ |v| v[:size]}.sum,
        value: rows.map{ |v| v[:value]}.sum,
      }
    end
  end

  def total
    (price * quantity)
  end

  def average_carrying
    return 0 if pool[:size] == 0

    pool[:value] / pool[:size]
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
