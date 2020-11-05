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

  def self.taxes_on(ammount, year, married = false)
    if married
      cut = PROGRESSIVE_RATES[year.to_s] * 2
    else
      cut = PROGRESSIVE_RATES[year.to_s]
    end

    [ammount, cut].min * LOW_RATE +
      [0, (ammount - cut)].max * HIGH_RATE

  end
end
