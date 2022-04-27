class StatsCalculator
  def self.stats_for_user(user, year)
    year_end = Date.new(year).end_of_year

    stock_ids(user).map do |id|
      stock = Stock.find_by_id(id)

      {
        name: stock.name,
        sym: stock.symbol,
        quantity_acquired: user.events.where(stock_id: id).where("executed_on <= ?", year_end).buy.sum(:quantity),
        quantity_sold: user.events.where(stock_id: id).where("executed_on <= ?", year_end).sell.sum(:quantity)
      }
    end
  end

  def self.stock_ids(user)
    user.events.order(:stock_id).pluck(:stock_id).uniq
  end
end
