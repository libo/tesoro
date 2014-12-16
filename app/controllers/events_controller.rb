class EventsController < ApplicationController
  before_action :set_event, only: [:show, :edit, :update, :destroy]
  before_action :set_stocks, only: [:edit, :new]
  before_action :set_actions, only: [:edit, :new]

  respond_to :html

  def index
    @events = Event.all.order(:executed_on)
    @total_capital_gain = Event.total_capital_gain(Date.today.year)
    respond_with(@events)
  end

  def new
    @event = Event.new
    respond_with(@event)
  end

  def edit
  end

  def create
    @event = Event.new(event_params)

    if @event.save
      flash[:notice] = 'Event was successfully created.'
      redirect_to events_path
    else
      render :new
    end
  end

  def update
    @event.update(event_params)
    flash[:notice] = 'Event was successfully updated.'

    redirect_to events_path
  end

  def destroy
    @event.destroy
    flash[:notice] = 'Event was removed.'

    redirect_to events_path
  end

  private

  def set_event
    @event = Event.find(params[:id])
  end

  def event_params
    params.require(:event).permit(
      :action,
      :stock_id,
      :quantity,
      :price,
      :commission,
      :executed_on
    )
  end

  def set_stocks
    @stocks = Stock.all
  end

  def set_actions
    @actions = Event.actions
  end
end
