require 'event_importer'

class ImportsController < ApplicationController
  respond_to :html, :csv

  def index
    @events = current_user.events.order(:executed_on).all
    @filename = "tesoro-#{Time.now.strftime("%Y-%m-%d_%H-%M-%S")}.csv"
  end

  def create
    if params[:wipe_all_exiting_event] == '1'
      current_user.events.destroy_all
    end

    EventImporter.import(params[:file].path, current_user.email)

    flash[:notice] = 'Data was successfully imported.'
    render :index
  end
end
