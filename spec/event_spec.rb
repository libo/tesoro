require 'spec_helper'

describe Event do
  let(:fiat) { Stock.create(name: 'Fiat Chrysler Automobiles NV', symbol: 'FCAU') }
  let(:user) { User.create(email: 'test@example.com', password: '123456', password_confirmation: '123456')}
  let(:currency) { Currency.create(name: 'Danish Krone', code: 'DKK', locale: :da, default_conversion_rate: 1) }

  it "passes Lars example 1" do
    # An individual buys shares in a listed company A as follows:
    # 1 Jan 2010: Purchase 100 shares for DKK 200
    # 1 Jan 2011: Purchase 200 shares for DKK 1,000
    # 1 Jan 2012: Purchase 300 shares for DKK 1,200
    Event.create(user: user, stock: fiat, action: :buy, quantity: 100, price: 2, executed_on: Date.parse('2010-1-1'), currency: currency)
    Event.create(user: user, stock: fiat, action: :buy, quantity: 200, price: 5, executed_on: Date.parse('2011-1-1'), currency: currency)
    e3 = Event.create(user: user, stock: fiat, action: :buy, quantity: 300, price: 4, executed_on: Date.parse('2012-1-1'), currency: currency)

    # At this point the individual’s share pool for company A shares is:
    # 1 Jan 2010      100     DKK   200
    # 1 Jan 2011      200     DKK 1,000
    # 1 Jan 2012      300     DKK 1,200
    # Pool            600     DKK 2,400
    # (with an average cost of DKK 4,00 per share)
    expect(e3.average_carrying).to eq(4.0)

    # On 1 Jan 2013 350 shares are sold for DKK 1,505
    e4 = Event.create(user: user, stock: fiat, action: :sell, quantity: 350, price: 4.3, executed_on: Date.parse('2013-1-1'), currency: currency)

    # Proceeds                   DKK 1,505
    # Cost ((350 / 600) x 2,400) DKK 1,400
    # Taxable gain               DKK   105
    expect(e4.capital_gain).to eq(105.0)

    # The following WAS NOT part of Lars' example

    # Pool               250     DKK 1,000
    expect(e4.pool[:size]).to eq(250)
    expect(e4.pool[:value]).to eq(1000)

    # On 1 Jan 2014 the remaining 250 shares are sold for DKK 2,500
    e5 = Event.create(user: user, stock: fiat, action: :sell, quantity: 250, price: 10, executed_on: Date.parse('2014-1-1'), currency: currency)

    # Proceeds                   DKK 2,500
    # Cost ((250 / 250) x 1,000) DKK 1,000
    # Taxable gain               DKK 1,500
    expect(e5.capital_gain).to eq(1500)

    # And just to be sure:
    expect(e5.pool[:size]).to eq(0)
    expect(e5.pool[:value]).to eq(0)
    expect(e5.average_carrying).to eq(0)
  end

  it "passes Lars example 2" do
    # A taxpayer acquired 400 shares of listed company X as follow:
    # 14 June 2005: Purchase 100 shares for DKK 9,500
    # 13 December 2006: Purchase of 200 shares for DKK 21,000
    # 5 July 2008: Purchase of 100 shares for DKK 10,700
    Event.create(user: user, stock: fiat, action: :buy, quantity: 100, price: 95, executed_on: Date.parse('2005-6-14'), currency: currency)
    Event.create(user: user, stock: fiat, action: :buy, quantity: 200, price: 105, executed_on: Date.parse('2006-12-13'), currency: currency)
    Event.create(user: user, stock: fiat, action: :buy, quantity: 100, price: 107, executed_on: Date.parse('2008-7-5'), currency: currency)

    # The share pool at this point is:
    # 14 Jun 2005      100      DKK  9,500
    # 13 Dec 2006      200      DKK 21,000
    # 05 Jul 2008      100      DKK 10,700
    #
    # Pool             400      DKK 41,200

    # 31 July 2009: Sale of 150 shares for DKK 16,500 (he keeps 250 shares).
    e4 = Event.create(user: user, stock: fiat, action: :sell, quantity: 150, price: 110, executed_on: Date.parse('2009-7-31'), currency: currency)

    # The capital gains on sale is therefore calculated as:
    # Proceeds                    DKK 16,500
    # Cost ((150 / 400) x 41,200) DKK 15,450
    # Capital gain                DKK  1,050
    expect(e4.capital_gain).to eq(1050.0)

    # The pool can now be restated as:
    # Pool (Bt Fwd)    400        DKK 41,200
    # Sale            (150)      (DKK 15,450)
    # Pool (C Fwd)     250        DKK 25,750

    # Then the individual buys more shares as follows:
    # 23 September 2010: Purchase 50 shares for DKK 5,000
    # 14 November 2011: Purchase 300 shares for DKK 32,250
    Event.create(user: user, stock: fiat, action: :buy, quantity: 50, price: 100, executed_on: Date.parse('2010-9-23'), currency: currency)
    Event.create(user: user, stock: fiat, action: :buy, quantity: 300, price: 107.5, executed_on: Date.parse('2011-11-14'), currency: currency)

    # The pool becomes:
    # Pool (Bt Fwd)    250        DKK 25,750
    # 23 Sep 2010       50        DKK  5,000
    # 14 Nov 2011      300        DKK 32,250
    #
    # Pool (C Fwd)     600        DKK 63,000

    # 13 March 2013: Sale 200 shares for DKK 21,600
    e7 = Event.create(user: user, stock: fiat, action: :sell, quantity: 200, price: 108, executed_on: Date.parse('2013-3-13'), currency: currency)

    # The capital gains on sale is therefore calculated as:
    # Proceeds                    DKK 21,600
    # Cost ((200 / 600) x 63,000) DKK 21,000
    # Capital gain                DKK    600
    expect(e7.capital_gain).to eq(600)

    # The pool can now be restated as:
    # Pool (Bt Fwd)    600        DKK 63,000
    # Sale            (200)      (DKK 21,000)
    # Pool (C Fwd)     400        DKK 42,000
    # (with an average cost of DKK 105 per share)
    expect(e7.average_carrying).to eq(105.00)
  end

  it "passes Skat.dk example 1" do
    # From: https://www.skat.dk/SKAT.aspx?oId=1843376
    #
    # Køb i år 2000, nominel værdi af aktierne = 50.000 kr. eller 500 aktier à 100 kr. Pris pr. aktie = 300 kr.
    # Køb i år 2001, nominel værdi af aktierne = 100.000 kr. eller 1000 aktier à 100 kr. Pris pr. aktie = 200 kr.
    # Køb i år 2006, nominel værdi af aktierne = 50.000 kr. eller 500 aktier à 100 kr. Pris pr. aktie = 150 kr.
    Event.create(user: user, stock: fiat, action: :buy, quantity: 500, price: 300, executed_on: Date.parse('2000-1-1'), currency: currency)
    Event.create(user: user, stock: fiat, action: :buy, quantity: 1000, price: 200, executed_on: Date.parse('2001-1-1'), currency: currency)
    e3 = Event.create(user: user, stock: fiat, action: :buy, quantity: 500, price: 150, executed_on: Date.parse('2006-1-1'), currency: currency)

    # Gennemsnitlig købesum pr. aktie, 425.000 kr. / 2.000 aktier = 212,50
    expect(e3.average_carrying).to eq(212.50)

    # Salgssum for 1.500 aktier i 2011 for 400.000 kr (Pris pr. aktie = 266,66 kr.)
    e4 = Event.create(user: user, stock: fiat, action: :sell, quantity: 1500, price: 266.6667, executed_on: Date.parse('2011-1-1'), currency: currency)

    # Gevinst = 81.250
    expect(e4.capital_gain.to_i).to eq(81250)
  end

  describe "#capital_gain" do
    it "handle case when the first event is a sell (empty pool)" do
      e = Event.create(user: user, stock: fiat, action: :sell, quantity: 500, price: 300, executed_on: Date.parse('2000-1-1'), currency: currency)

      expect { e.capital_gain }.to_not raise_error
    end
  end
end
