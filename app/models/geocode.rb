class Geocode
 include ActiveModel::Model

  attr_accessor :zip_code,
              :latitude,
              :longitude,
              :city,
              :state
end
