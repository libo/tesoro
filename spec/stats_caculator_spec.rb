require 'spec_helper'
require 'stats_calculator'

describe StatsCalculator do
  let(:fiat) { Stock.create(name: 'Fiat Chrysler Automobiles NV', symbol: 'FCAU') }
  let(:moderna) { Stock.create(name: 'Moderna', symbol: 'MRNA') }

  let(:user) { User.create(email: 'test@example.com', password: '12345678', password_confirmation: '12345678')}
  let(:currency) { Currency.create(name: 'Danish Krone', code: 'DKK', locale: :da, default_conversion_rate: 1) }

  let(:other) { Stock.create(name: 'Other', symbol: 'OTHER') }
  let(:other_user) { User.create(email: 'test2@example.com', password: '11111111', password_confirmation: '11111111')}

  before do
    Event.create(user: user, stock: fiat, action: :buy, quantity: 100, price: 2, executed_on: Date.parse('2010-1-1'), currency: currency)
    Event.create(user: user, stock: moderna, action: :buy, quantity: 100, price: 2, executed_on: Date.parse('2010-1-1'), currency: currency)
    Event.create(user: user, stock: fiat, action: :sell, quantity: 30, price: 2, executed_on: Date.parse('2010-1-1'), currency: currency)
    Event.create(user: user, stock: moderna, action: :sell, quantity: 10, price: 2, executed_on: Date.parse('2010-1-1'), currency: currency)

    Event.create(user: other_user, stock: other, action: :buy, quantity: 100, price: 2, executed_on: Date.parse('2010-1-1'), currency: currency)
  end

  describe ".stock_ids" do
    it "returns correct list of owned stocks" do
      expect(StatsCalculator.stock_ids(user)).to eq([fiat.id, moderna.id])
      expect(StatsCalculator.stock_ids(other_user)).to eq([other.id])
    end
  end

  describe ".stats_for_user" do
    it "returns the stats" do
      expected = [
        {:name=>"Fiat Chrysler Automobiles NV", :quantity_acquired=>100, :quantity_sold=>30, :sym=>"FCAU"},
        {:name=>"Moderna", :quantity_acquired=>100, :quantity_sold=>10, :sym=>"MRNA"}
      ]

      expect(StatsCalculator.stats_for_user(user)).to eq(expected)
    end
  end
end
