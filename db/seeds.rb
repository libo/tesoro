if Stock.where(symbol: 'ZEN').count == 0
  Stock.create(name: 'Zendesk', symbol: 'ZEN')
end

if Currency.where(code: 'DKK').count == 0
  Currency.create(name: 'Danish Krone', code: 'DKK')
end
