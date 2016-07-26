require 'geocoder/lookups/base'
require "geocoder/results/amap"

module Geocoder::Lookup
  class Amap < Base

    def name
      "Amap"
    end

    def required_api_key_parts
      ["key"]
    end

    def query_url(query)
      "#{protocol}://restapi.amap.com/v3/geocode/geo?" + url_query_string(query)
    end

    # HTTP only
    def supported_protocols
      [:http]
    end

    private # ---------------------------------------------------------------

    def results(query, reverse = false)
      return [] unless doc = fetch_data(query)
      info, infocode = format_info(doc), doc['infocode'].to_i
      if infocode == 10000
        return doc['geocodes'] if doc['geocodes'].present?
      else
        error_type = fetch_error_type(infocode)
        raise_error(error_type, "#{info}.") || Geocoder.log(:warn, "Amap Geocoding API error: #{info}.")
      end
      return []
    end

    def fetch_error_type(infocode)
      hash_exceptions.select{|k, v| v.include? infocode}.keys.first.constantize
    end

    def hash_exceptions
      {
        "Geocoder::Error"               => [30001, 20003],
        "Geocoder::InvalidRequest"      => [20000, 20001, 20002, 20800, 20801, 20802, 20803],
        "Geocoder::InvalidApiKey"       => [10001, 10009, 10012],
        "Geocoder::RequestDenied"       => [10002, 10005, 10006, 10007, 10008, 10011, 10012],
        "Geocoder::OverQueryLimitError" => [10003, 10004, 10010]
      }
    end

    def format_info(doc)
      doc['info'].split(',').first.downcase.tr('_', ' ')
    end

    def query_url_amap_params(query)
      params = {
        address: query.sanitized_text,
        output:  'json'
      }
      %w(city sig callback).each do |field|
        instance_eval <<-EOF
          unless (value = query.options[:#{field}]).nil?
            params[:#{field}] = value
          end
        EOF
      end
      params
    end

    def query_url_params(query)
      query_url_amap_params(query).merge(
        key: configuration.api_key,
      ).merge(super)
    end

  end
end
