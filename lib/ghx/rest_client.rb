require "net/http"

module GHX
  # RestClient is a simple wrapper around Net::HTTP to make it easier to make API calls to the GitHub REST API.
  #
  # This is necessary because not all GitHub API endpoints are covered by Octokit.
  class RestClient
    attr_reader :api_key

    # @param api_key [String] the GitHub API key
    def initialize(api_key)
      @api_key = api_key
    end

    # Make a GET request to the given path
    # @param path [String] the path to the API endpoint
    # @return [Hash] the parsed JSON response
    def get(path)
      uri = URI.parse("https://api.github.com/#{path}")
      request = Net::HTTP::Get.new(uri)

      response = _http_request(uri: uri, request: request)

      JSON.parse(response.body)
    end

    # Make a POST request to the given path with the given params
    # @param path [String] the path to the API endpoint
    # @param params [Hash] the request body
    # @return [Hash] the parsed JSON response
    def post(path, params)
      uri = URI.parse("https://api.github.com/#{path}")
      request = Net::HTTP::Post.new(uri)

      request.body = params.to_json

      response = _http_request(uri: uri, request: request)

      JSON.parse(response.body)
    end

    # Make a PATCH request to the given path with the given params
    # @param path [String] the path to the API endpoint
    # @param params [Hash] the request body
    # @return [Hash] the parsed JSON response
    def patch(path, params)
      uri = URI.parse("https://api.github.com/#{path}")
      request = Net::HTTP::Patch.new(uri)

      request.body = params.to_json

      response = _http_request(uri: uri, request: request)

      JSON.parse(response.body)
    end

    private

    def _http_request(uri:, request:)
      request["Accept"] = "application/vnd.github+json"
      request["Authorization"] = "Bearer #{@api_key}"
      request["X-Github-Api-Version"] = "2022-11-28"

      req_options = {
        use_ssl: uri.scheme == "https"
      }

      response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
        http.request(request)
      end

      if response.code.to_i < 400
        response
      elsif [403, 429].include?(response.code.to_i)
        if response["X-RateLimit-Remaining"].to_i == 0
          reset_time = Time.at(response["X-RateLimit-Reset"].to_i)
          raise GHX::RateLimitExceededError, "GitHub API rate limit exceeded. Try again after #{reset_time}"
        else
          raise GHX::RateLimitExceededError, "GitHub API rate limit exceeded. Try again later."
        end
      else
        raise GHX::OtherApiError, "GitHub API returned an error: #{response.code} #{response.body}"
      end
    end
  end
end
