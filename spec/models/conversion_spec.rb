require 'spec_helper'

describe Conversion do
  describe "validation" do
    subject {
      Conversion.new(book_on: DateTime.now,
        currency: Currency.new(name: 'Euro', code: 'EUR'),
        rate: 123)
    }

    it "is valid with valid attributes" do
      expect(subject).to be_valid
    end

    it "is not valid without a book_on" do
      subject.book_on = nil
      expect(subject).to_not be_valid
    end

    it "is not valid without a currency" do
      subject.currency = nil
      expect(subject).to_not be_valid
    end

    it "is not valid without a rate" do
      subject.rate = nil
      expect(subject).to_not be_valid
    end
  end
end
