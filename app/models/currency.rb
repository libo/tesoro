class Currency < ActiveRecord::Base
  validates :name, presence: true
  validates :code, presence: true
  validates :locale, presence: true
  validates :default_conversion_rate, presence: true

  DEFAULT_CURRENCY = 'DDK'

  def self.most_used_in_events_id
    if event = Event.last
      event.currency.id
    end
  end

  # Return a conversion rate
  #
  # If the conversion rate is not available for the date look for
  # the previous day(s), if that is not available falls back to
  # a default_conversion_rate
  def conversion_rate_to_default_currency(on)
    return 1 if code.upcase == DEFAULT_CURRENCY

    cache_key = "conversion_on/#{on}"

    Rails.cache.fetch(cache_key) do
      conversion = Conversion.where(book_on: on).where(currency: self).first

      if conversion.present?
        conversion.rate
      elsif nc = near_conversion(on)
        nc.rate
      else
        default_conversion_rate
      end
    end
  end

  private

  def near_conversion(on)
    Conversion.where("book_on < ?", on).
      order("book_on DESC").
      where(currency: self).first
  end
end
