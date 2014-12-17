require 'smarter_csv'

class Conversion < ActiveRecord::Base
  belongs_to :currency

  validates :currency, presence: true
  validates :book_on, presence: true
  validates :rate, presence: true

  def self.import(code)
    currency = Currency.where(code: code.upcase).first

    if currency.present?
      options = {
        col_sep: ";"
      }

      path = Rails.root.join("db", "currency_seeds", "#{code.downcase}.csv")

      SmarterCSV.process(path, options).each do |row|
        if Conversion.where(book_on: row[:date]).count == 0
          rate = row[:rate].gsub(",",".").to_f/100
          Conversion.create!(book_on: Date.parse(row[:date]), rate: rate, currency: currency)
        end
      end
    end
  end
end
