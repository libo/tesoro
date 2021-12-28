require 'smarter_csv'

class Conversion < ApplicationRecord
  belongs_to :currency

  validates :currency, presence: true
  validates :book_on, presence: true
  validates :rate, presence: true

  def self.wipe_and_import(code)
    currency = Currency.where(code: code.upcase).first

    if currency.present?
      options = {
        col_sep: ";"
      }

      path = Rails.root.join("db", "currency_seeds", "#{code.downcase}.csv")

      currency.conversions.delete_all

      SmarterCSV.process(path, options).each do |row|
        book_on = Date.parse(row[:date])
        rate = row[:rate].gsub(",",".").to_f/100
        Conversion.create!(book_on: book_on, rate: rate, currency: currency)
      end

      # We must recompute all numbers...
      Rails.cache.clear
    end
  end
end
