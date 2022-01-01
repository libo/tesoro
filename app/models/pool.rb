class Pool
  def self.for_event(event)
    cache_key = Digest::SHA1.hexdigest(event.cache_key_with_version)

    Rails.cache.fetch("event_pool/#{cache_key}", expires_in: 12.hours) do
      previous_pool = if event.previous_event.present?
                        for_event(event.previous_event)
                      else
                        new
                      end

      pool = new(value: previous_pool.value, size: previous_pool.size)

      if event.buy?
        pool.add_purchase(event)
      else
        pool.add_sale(event)
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
