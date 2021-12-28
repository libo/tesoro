require 'spec_helper'

describe Currency do
  let(:ddk) {
    Currency.new(name: 'Danish Krone',
      code: 'DKK',
      locale: :da,
      default_conversion_rate: 1)
  }

  let(:usd_default_conversion_rate) { 6 }
  let(:usd) {
    Currency.new(name: 'US Dollar',
      code: 'USD',
      locale: :en_us,
      default_conversion_rate: usd_default_conversion_rate)
  }

  let(:book_on) { Date.parse('2010-1-1') }

  describe "validation" do
    subject {
      Currency.new(name: "Anything",
        code: 'USD',
        locale: :en_us,
        default_conversion_rate: 1)
    }

    it "is valid with valid attributes" do
      expect(subject).to be_valid
    end

    it "is not valid without a name" do
      subject.name = nil
      expect(subject).to_not be_valid
    end

    it "is not valid without a code" do
      subject.code = nil
      expect(subject).to_not be_valid
    end

    it "is not valid without a default_conversion_rate" do
      subject.default_conversion_rate = nil
      expect(subject).to_not be_valid
    end
  end

  describe "#conversion_rate_to_default_currency" do
    it "returns 1 when DEFAULT_CURRENCY (DKK)" do
      expect(ddk.conversion_rate_to_default_currency(book_on)).to eq(1)
    end

    it "returns default conversion rate when 0 conversion are avaliable" do
      expect(usd_default_conversion_rate).to eq(usd.conversion_rate_to_default_currency(book_on))
    end

    it "returns the conversion rate on the day when available" do
      Conversion.create(book_on: book_on-1.day, rate: 12, currency: usd)
      Conversion.create(book_on: book_on, rate: 34, currency: usd)
      Conversion.create(book_on: book_on+1.day, rate: 56, currency: usd)

      expect(usd.conversion_rate_to_default_currency(book_on)).to eq(34)
    end

    it "returns the conversion rate on previous day when on day is not available" do
      Conversion.create(book_on: book_on-2.day, rate: 99, currency: usd)
      Conversion.create(book_on: book_on-1.day, rate: 12, currency: usd)

      expect(usd.conversion_rate_to_default_currency(book_on)).to eq(12)
    end

    describe "cachinng" do
      let(:memory_store) { ActiveSupport::Cache.lookup_store(:memory_store) }

      before do
        allow(Rails).to receive(:cache).and_return(memory_store)
        Rails.cache.clear
      end

      it "doesn't collide cache on two different days" do
        Conversion.create(book_on: book_on-1.day, rate: 12, currency: usd)
        Conversion.create(book_on: book_on, rate: 34, currency: usd)

        expect(usd.conversion_rate_to_default_currency(book_on-1.day)).to eq(12)
        expect(usd.conversion_rate_to_default_currency(book_on)).to eq(34)
      end

      it "doesn't collide cache on two different currencies" do
        eur = Currency.new(name: 'Euro', code: 'EUR')

        Conversion.create(book_on: book_on, rate: 12, currency: eur)
        Conversion.create(book_on: book_on, rate: 34, currency: usd)

        expect(eur.conversion_rate_to_default_currency(book_on)).to eq(12)
        expect(usd.conversion_rate_to_default_currency(book_on)).to eq(34)
      end
    end
  end
end
