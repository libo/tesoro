class Event < ActiveRecord::Base
  belongs_to :stock

  enum action: [ :buy, :sell ]

  def average_carrying
    this_and_previous_acquisitions.sum(:price) /
      this_and_previous_acquisitions.count
  end

  private

  def this_and_previous

  end

  def this_and_previous_acquisitions
    Event.buy.order(:executed_on)
      .where("executed_on <= ?", executed_on)
  end

  def this_and_previous_sell
    Event.sell.order(:executed_on)
      .where("executed_on <= ?", executed_on)
  end
end
