class EventsController < ApplicationController
  before_action :set_event, only: [:show, :edit, :update, :destroy]
  before_action :set_stocks, only: [:edit, :new]
  before_action :set_actions, only: [:edit, :new]
  before_action :set_currencies, only: [:edit, :new]

  respond_to :html, :csv

  def index
    @events = current_user.events.order(:executed_on).all
    @total_capital_gain = current_user.events.total_capital_gain(Date.today.year)
    respond_with(@events)
  end

  def new
    @event = current_user.events.new
    respond_with(@event)
  end

  def edit
  end

  def create
    @event = current_user.events.new(event_params)

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
    @event = current_user.events.find(params[:id])
  end

  def event_params
    params.require(:event).permit(
      :action,
      :stock_id,
      :quantity,
      :price,
      :commission,
      :currency_id,
      :executed_on
    )
  end

  def set_stocks
    @stocks = Stock.all
  end

  def set_actions
    @actions = Event.actions
  end

  def set_currencies
    @currencies = Currency.all
  end
end
