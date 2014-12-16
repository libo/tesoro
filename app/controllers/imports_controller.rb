class ImportsController < ApplicationController
  respond_to :html, :csv

  def index
    @events = current_user.events.order(:executed_on).all

    respond_with(@events)
  end
end
