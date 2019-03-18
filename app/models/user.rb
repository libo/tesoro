class User < ApplicationRecord
  has_many :events

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  def quantity_sold
    events.sell.sum(:quantity)
  end

  def quantity_acquired
    events.buy.sum(:quantity)
  end
end
