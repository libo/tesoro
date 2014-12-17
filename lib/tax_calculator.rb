class TaxCalculator
  def self.taxes_on(ammount, year, married = false)
    # todo make it parametric on year

    if married
      cut = 99800
    else
      cut = 49900
    end

    percentage_1 = 0.27
    percentage_2 = 0.42

    [ammount, cut].min * percentage_1 +
      [0, (ammount - cut)].max * percentage_2

  end
end
