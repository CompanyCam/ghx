require 'net/http'

module GHX
  class RestClient
    attr_reader :api_key

    def initialize(api_key)
      @api_key = api_key
    end

    # @return [Hash] the JSON response
    def get(path)
      uri = URI.parse("https://api.github.com/#{path}")
      request = Net::HTTP::Get.new(uri)
      request["Accept"] = "application/vnd.github+json"
      request["Authorization"] = "Bearer #{@api_key}"
      request["X-Github-Api-Version"] = "2022-11-28"

      req_options = {
        use_ssl: uri.scheme == "https",
      }

      response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
        http.request(request)
      end

      JSON.parse(response.body)
    end

    # @return [Hash] the JSON response
    def post(path, params)
      uri = URI.parse("https://api.github.com/#{path}")
      request = Net::HTTP::Post.new(uri)
      request["Accept"] = "application/vnd.github+json"
      request["Authorization"] = "Bearer #{@api_key}"
      request["X-Github-Api-Version"] = "2022-11-28"

      req_options = {
        use_ssl: uri.scheme == "https",
      }

      request.body = params.to_json

      response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
        http.request(request)
      end

      JSON.parse(response.body)
    end

    # @return [Hash] the JSON response
    def patch(path, params)
      uri = URI.parse("https://api.github.com/#{path}")
      request = Net::HTTP::Patch.new(uri)
      request["Accept"] = "application/vnd.github+json"
      request["Authorization"] = "Bearer #{@api_key}"
      request["X-Github-Api-Version"] = "2022-11-28"

      req_options = {
        use_ssl: uri.scheme == "https",
      }

      request.body = params.to_json

      response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
        http.request(request)
      end

      JSON.parse(response.body)
    end

  end
end