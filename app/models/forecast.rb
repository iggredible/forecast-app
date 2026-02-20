class Forecast
  include ActiveModel::Model

  attr_accessor :current_temp,
              :high,
              :low,
              :extended_forecast,
              :cached,
              :zip_code,
              :city,
              :state
end
