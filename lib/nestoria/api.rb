require 'json'
require 'net/http'
require 'uri'

# Easy url encoding of hashes
class Hash
  def to_query
    self.map{|k,v| "#{k}=#{v}"}.join("&")
  end
end

module Nestoria
  
  class BadLocation < StandardError; end
  class InvalidRequest < StandardError; end
  class InternalError < StandardError; end
  class InvalidVersion < StandardError; end
  
  class Api
    
    API_VERSION = 1.19
    
    # Valid search parameters - See http://www.nestoria.co.uk/help/api-search-listings for key/value details
    LOCATION_KEYS = [ :place_name, :south_west, :north_east, :centre_point, :radius ]
    SEARCH_KEYS   = [ :guid, :listing_type, :property_type, :price_min, :price_max,
      :bedroom_min, :bedroom_max, :room_min, :room_max, :bathroom_min, :bathroom_max, 
      :size_min, :size_max, :keywords, :keywords_exclude, :has_photo, :updated_min, 
      :number_of_results, :page, :sort ] + LOCATION_KEYS
    
    def initialize(country)
      @country = country
    end
    
    # Search nestoria property listings - See http://www.nestoria.co.uk/help/api-search-listings
    def search(params)        
      invalid_keys = params.keys - SEARCH_KEYS
      raise InvalidRequest.new "Invalid keys: #{invalid_keys.join(", ")}" unless invalid_keys.empty?
      
      # Convert arrays into CSVs
      [:keywords, :keywords_exclude].each do |key|
        params[key] = params[key].join(",") unless params[key].nil?
      end
      
      # Convert any Time/DateTime objects to UNIX time integers
      params[:updated_min] = params[:updated_min].to_i unless params[:updated_min].nil?
      
      process_location! params
      
      request :search_listings, params
    end
    
    # List of keywords that can be used in search - See http://www.nestoria.co.uk/help/api-keywords
    def keywords
      response = request :keywords
      keywords = Hash.new
      response["labels"].each do |label|
        keywords[label["keyword"]] = label["content"]
      end
      keywords
    end
    
    # Average house price for an area - See http://www.nestoria.co.uk/help/api-metadata
    def metadata(params)
      invalid_keys = params.keys - LOCATION_KEYS
      raise InvalidRequest.new "Invalid keys: #{invalid_keys.join(", ")}" unless invalid_keys.empty?
      
      process_location! params
      
      request :metadata, params
    end
    
    # Test URL request, returns whatever params you put in
    def echo(params = {:foo => "bar"})
      request :echo, params
    end
    
    private
    
    def base_url
      domains = {:au => "api.nestoria.com.au",
                 :br => "api.nestoria.com.br",
                 :de => "api.nestoria.de",
                 :es => "api.nestoria.es",
                 :fr => "api.nestoria.fr",
                 :in => "api.nestoria.in",
                 :it => "api.nestoria.it",
                 :uk => "api.nestoria.co.uk"}
       "http://#{domains[@country]}/api"
    end
    
    def process_location!(params)
      [:south_west, :north_east, :centre_point].each do |key|
        params[key] = params[key].join(",") unless params[key].nil?
      end
    end
    
    def request(action, params = {})
      url = "#{base_url}?version=#{API_VERSION}&action=#{action}&encoding=json&#{params.to_query}"
      puts url
      res = Net::HTTP.get_response(URI.parse(url))
      data = JSON.parse(res.body)
      
      # Catch any errors returned from the API and raise an appropriate exception
      if action.to_s == "search"
        application_response_code = data["response"]["application_response_code"]
        application_response_text = data["response"]["application_response_text"]
        case application_response_code.to_i
        when 200...299
          raise BadLocation.new "#{application_response_code}, #{application_response_text}"
        when 500
          raise InternalError.new "#{application_response_code}, #{application_response_text}"
        when 910...911
          raise InvaidVersion.new "#{application_response_code}, #{application_response_text}"
        when 900...999
          raise InvalidRequest.new "#{application_response_code}, #{application_response_text}"
        end
      end
      
      data["response"]
    end
    
  end
end