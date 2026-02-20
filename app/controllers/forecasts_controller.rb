class ForecastsController < ApplicationController
  def index
  end

  def show
    address = params[:address]

    if address.blank?
      redirect_to root_path, alert: "Please enter an address."
      return
    end

    @forecast = ForecastService.new.call(address)
    @address = address
  rescue StandardError => e
    redirect_to root_path, alert: e.message
  end
end
