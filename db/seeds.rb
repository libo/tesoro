if Stock.where(symbol: 'ZEN').count == 0
  Stock.create(name: 'Zendesk', symbol: 'ZEN')
end

if Currency.where(code: 'DKK').count == 0
  Currency.create(name: 'Danish Krone', code: 'DKK', locale: :da, default_conversion_rate: 1)
end

if Currency.where(code: 'USD').count == 0
  Currency.create(name: 'US Dollar', code: 'USD', locale: :en_us, default_conversion_rate: 6)
end

if Rails.env.development?
  Event.destroy_all
  zen = Stock.where(symbol: 'ZEN').first
  currency = Currency.where(code: 'DKK').first
  user = User.last

  if user.present?
    user.events.create(stock: zen, action: :buy, currency: currency, quantity: 100, price: 95, executed_on: 10.days.ago)
    user.events.create(stock: zen, action: :buy, currency: currency, quantity: 200, price: 105, executed_on: 9.days.ago)
    user.events.create(stock: zen, action: :buy, currency: currency, quantity: 100, price: 107, executed_on: 8.days.ago)

    user.events.create(stock: zen, action: :sell, currency: currency, quantity: 150, price: 110, executed_on: 5.days.ago)

    user.events.create(stock: zen, action: :buy, currency: currency, quantity: 50, price: 100, executed_on: 4.days.ago)
    user.events.create(stock: zen, action: :buy, currency: currency, quantity: 300, price: 107.5, executed_on: 3.days.ago)

    user.events.create(stock: zen, action: :sell, currency: currency, quantity: 200, price: 108, executed_on: 2.days.ago)
  end
end
