class Stock < ActiveRecord::Base
  has_many :events
end
