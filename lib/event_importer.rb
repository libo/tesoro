class EventImporter
  def self.import(path, email)
    options = {
      col_sep: ","
    }

    user = User.find_by_email(email)

    SmarterCSV.process(path, options).each do |row|
      stock = Stock.find_by_symbol(row[:symbol].upcase)
      currency = Currency.find_by_code(row[:currency].upcase)

      Event.create!(
        user: user,
        stock: stock,
        executed_on: row[:executed_on],
        action: row[:action],
        quantity: row[:quantity],
        price: row[:price],
        commission: row[:commission],
        currency: currency
      )
    end
  end
end
