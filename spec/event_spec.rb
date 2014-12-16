require 'spec_helper'

describe Event do
  let(:zen) { Stock.create(name: 'Zendesk', symbol: 'ZEN') }
  let(:user) { User.create(email: 'test@example.com', password: '123456', password_confirmation: '123456')}
  let(:currency) { Currency.create(name: 'Danish Krone', code: 'DKK', locale: :da, default_conversion_rate: 1) }

  it "passes Lars example 1" do
    # An individual buys shares in a listed company A as follows:
    # 1 Jan 2010: Purchase 100 shares for DKK 200
    # 1 Jan 2011: Purchase 200 shares for DKK 1,000
    # 1 Jan 2012: Purchase 300 shares for DKK 1,200                                                                                DKK    100
    Event.create(user: user, stock: zen, action: :buy, quantity: 100, price: 2, executed_on: 10.days.ago, currency: currency)
    Event.create(user: user, stock: zen, action: :buy, quantity: 200, price: 5, executed_on: 9.days.ago, currency: currency)
    e3 = Event.create(stock: zen, action: :buy, quantity: 300, price: 4, executed_on: 8.days.ago, currency: currency)

    # At this point the individual’s share pool for company A shares is:
    # 1 Jan 2010      100     DKK   200
    # 1 Jan 2011      200     DKK 1,000
    # 1 Jan 2012      300     DKK 1,200
    # Pool            600     DKK 2,400
    # (with an average cost of DKK 4,00 per share)
    e3.average_carrying.should == 4.0

    # On 1 Jan 2013 350 shares are sold for DKK 1,505
    e4 = Event.create(user: user, user: user, stock: zen, action: :sell, quantity: 350, price: 4.3, executed_on: 5.days.ago, currency: currency)

    # Proceeds                   DKK 1,505
    # Cost ((350 / 600) x 2,400) DKK 1,400
    # Taxable gain               DKK   105
    e4.capital_gain.should == 105.0
  end

  it "passes Lars example 2" do
    # A taxpayer acquired 400 shares of listed company X as follow:
    # 14 June 2005: Purchase 100 shares for DKK 9,500
    # 13 December 2006: Purchase of 200 shares for DKK 21,000
    # 5 July 2008: Purchase of 100 shares for DKK 10,700
    Event.create(user: user, stock: zen, action: :buy, quantity: 100, price: 95, executed_on: 10.days.ago, currency: currency)
    Event.create(user: user, stock: zen, action: :buy, quantity: 200, price: 105, executed_on: 9.days.ago, currency: currency)
    Event.create(user: user, stock: zen, action: :buy, quantity: 100, price: 107, executed_on: 8.days.ago, currency: currency)

    # The share pool at this point is:
    # 14 Jun 2005      100      DKK  9,500
    # 13 Dec 2006      200      DKK 21,000
    # 05 Jul 2008      100      DKK 10,700
    #
    # Pool             400      DKK 41,200

    # 31 July 2009: Sale of 150 shares for DKK 16,500 (he keeps 250 shares).
    e4 = Event.create(user: user, user: user, stock: zen, action: :sell, quantity: 150, price: 110, executed_on: 5.days.ago, currency: currency)

    # The capital gains on sale is therefore calculated as:
    # Proceeds                    DKK 16,500
    # Cost ((150 / 400) x 41,200) DKK 15,450
    # Capital gain                DKK  1,050
    e4.capital_gain.should == 1050.0

    # The pool can now be restated as:
    # Pool (Bt Fwd)    400        DKK 41,200
    # Sale            (150)      (DKK 15,450)
    # Pool (C Fwd)     250        DKK 25,750

    # Then the individual buys more shares as follows:
    # 23 September 2010: Purchase 50 shares for DKK 5,000
    # 14 November 2011: Purchase 300 shares for DKK 32,250
    Event.create(user: user, stock: zen, action: :buy, quantity: 50, price: 100, executed_on: 4.days.ago, currency: currency)
    Event.create(user: user, stock: zen, action: :buy, quantity: 300, price: 107.5, executed_on: 3.days.ago, currency: currency)

    # The pool becomes:
    # Pool (Bt Fwd)    250        DKK 25,750
    # 23 Sep 2010       50        DKK  5,000
    # 14 Nov 2011      300        DKK 32,250
    #
    # Pool (C Fwd)     600        DKK 63,000

    # 13 March 2013: Sale 200 shares for DKK 21,600
    e7 = Event.create(user: user, stock: zen, action: :sell, quantity: 200, price: 108, executed_on: 2.days.ago, currency: currency)

    # The capital gains on sale is therefore calculated as:
    # Proceeds                    DKK 21,600
    # Cost ((200 / 600) x 63,000) DKK 21,000
    # Capital gain                DKK    600
    e7.capital_gain.should == 600

    # The pool can now be restated as:
    # Pool (Bt Fwd)    600        DKK 63,000
    # Sale            (200)      (DKK 21,000)
    # Pool (C Fwd)     400        DKK 42,000
    # (with an average cost of DKK 105 per share)
    e7.average_carrying.should == 105.00
  end
end
