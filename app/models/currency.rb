class Currency < ActiveRecord::Base
  validates :name, presence: true
  validates :code, presence: true
  validates :locale, presence: true
  validates :default_conversion_rate, presence: true

  DEFAULT_CURRENCY = 'DDK'

  def conversion_rate_to_default_currency(on)
    return 1 if code.upcase == DEFAULT_CURRENCY

    conversion = Conversion.where(book_on: on).where(currency: self).first

    if conversion.present?
      conversion.rate
    else
      default_conversion_rate
    end
  end
end
