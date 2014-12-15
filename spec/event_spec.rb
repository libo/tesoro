require 'spec_helper'

describe Event do
  it "passes Lars example 1" do
    zen = Stock.create(name: 'Zendesk', symbol: 'ZEN')
    Event.create(stock: zen, action: :buy, quantity: 100, price: 2, executed_on: 10.days.ago)
    Event.create(stock: zen, action: :buy, quantity: 200, price: 5, executed_on: 9.days.ago)
    e3 = Event.create(stock: zen, action: :buy, quantity: 300, price: 4, executed_on: 8.days.ago)

    e3.average_carrying.should == 4.0

    e4 = Event.create(stock: zen, action: :sell, quantity: 350, price: 4.3, executed_on: 5.days.ago)

    e4.capital_gain.should == 105.0
  end
end
