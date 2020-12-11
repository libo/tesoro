class TaxCalculator
  # From SKAT Satser https://www.skat.dk/SKAT.aspx?oId=2035568
  PROGRESSIVE_RATES = {
    "2021" => 56500,
    "2020" => 55300,
    "2019" => 54000,
    "2018" => 52900,
    "2017" => 51700,
    "2016" => 50600,
    "2015" => 49900
  }
  LOW_RATE = 0.27
  HIGH_RATE = 0.42

  def self.taxes_on(amount, cut:)
    [amount, cut].min * LOW_RATE +
      [0, (amount - cut)].max * HIGH_RATE
  end

  class Married
    def self.taxes_on(amount, year)
      cut = PROGRESSIVE_RATES[year.to_s] * 2
      TaxCalculator.taxes_on(amount, cut: cut)
    end
  end

  class Unmarried
    def self.taxes_on(amount, year)
      cut = PROGRESSIVE_RATES[year.to_s]
      TaxCalculator.taxes_on(amount, cut: cut)
    end
  end
end
