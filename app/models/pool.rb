class Pool
  def self.for_event(event)
    cache_key = Digest::SHA1.hexdigest(event.this_and_previous_events.map(&:cache_key_with_version).join('/'))

    Rails.cache.fetch("event_pool/#{cache_key}", expires_in: 12.hours) do
      pool = new

      event.this_and_previous_events.each do |event|
        if event.buy?
          pool.add_purchase(event)
        else
          pool.add_sale(event)
        end
      end

      pool
    end
  end

  def initialize(value: 0, size: 0)
    self.value = value
    self.size = size
  end
  attr_reader :value, :size

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

  private

  attr_writer :value, :size
end
