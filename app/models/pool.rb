class Pool < ApplicationRecord
  belongs_to :event

  def self.recalculate(event)
    # When deleting an event, its ID is not in "this_and_following_events".
    Pool.where(event_id: event.id).delete_all if event.destroyed?

    later_event_ids = event.this_and_following_events.pluck(:id)

    # After deleting the last event, do nothing.
    return if later_event_ids.empty?

    # Delete the Pool for this event and all after it
    Pool.where(event_id: later_event_ids).delete_all

    # (Recursively) add a Pool for this event and all after it
    last_event = Event.find(later_event_ids.last)
    create_event(last_event)
  end

  NullPool = Struct.new(:value, :size).new(0, 0)

  def self.create_event(event)
    previous_pool = if event.previous_event.present?
      find_by(event: event.previous_event) || create_event(event.previous_event)
    else
      NullPool
    end

    pool = new(event: event)
    pool.value = previous_pool.value
    pool.size = previous_pool.size

    if event.buy?
      pool.add_purchase(event)
    else
      pool.add_sale(event)
    end

    pool.save!

    pool
  end

  def empty?
    size == 0
  end

  def add_purchase(event)
    self.value += event.total
    self.size += event.quantity
  end

  def add_sale(event)
    return if empty?

    self.value -= ((event.quantity.to_f / size.to_f) * value).round(2)
    self.size -= event.quantity
  end
end
