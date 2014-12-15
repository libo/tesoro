require 'spec_helper'

describe Event do
  let(:zen) { Stock.create(name: 'Zendesk', symbol: 'ZEN') }

  it "passes Lars example 1" do
    Event.create(stock: zen, action: :buy, quantity: 100, price: 2, executed_on: 10.days.ago)
    Event.create(stock: zen, action: :buy, quantity: 200, price: 5, executed_on: 9.days.ago)
    e3 = Event.create(stock: zen, action: :buy, quantity: 300, price: 4, executed_on: 8.days.ago)

    e3.average_carrying.should == 4.0

    e4 = Event.create(stock: zen, action: :sell, quantity: 350, price: 4.3, executed_on: 5.days.ago)

    e4.capital_gain.should == 105.0
  end

  it "passes Lars example 2" do
    Event.create(stock: zen, action: :buy, quantity: 100, price: 95, executed_on: 10.days.ago)
    Event.create(stock: zen, action: :buy, quantity: 200, price: 105, executed_on: 9.days.ago)
    e3 = Event.create(stock: zen, action: :buy, quantity: 100, price: 107, executed_on: 8.days.ago)

    e3.average_carrying.should == 103.0

    e4 = Event.create(stock: zen, action: :sell, quantity: 150, price: 110, executed_on: 5.days.ago)

    e4.capital_gain.should == 1050.0

    Event.create(stock: zen, action: :buy, quantity: 50, price: 100, executed_on: 4.days.ago)
    Event.create(stock: zen, action: :buy, quantity: 300, price: 107.5, executed_on: 3.days.ago)

    e4 = Event.create(stock: zen, action: :sell, quantity: 200, price: 108, executed_on: 2.days.ago)

    e4.capital_gain.should == 600
  end
end
