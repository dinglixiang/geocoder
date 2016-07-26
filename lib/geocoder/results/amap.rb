require 'geocoder/results/base'

module Geocoder::Result
  class Amap < Base

    def coordinates
      @data['location'].split(',')
    end

    def address
      @data['formatted_address']
    end

    def state
      province
    end

    def province
      @data['province']
    end

    def city
      @data['city']
    end

    def district
      @data['district']
    end

    def street
      @data['street']
    end

    def street_number
      @data['number']
    end

    def formatted_address
      @data['formatted_address']
    end

    def address_components
      formatted_address
    end

    def state_code
      @data['cityCode']
    end

    def postal_code
      @data['adcode']
    end

    def country
      "China"
    end

    def country_code
      "CN"
    end

    def city_code
      @data['cityCode']
    end
  end
end
