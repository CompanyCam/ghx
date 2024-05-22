module GHX
  # Internal class to interact with the GitHub GraphQL API
  class GraphqlClient
    # @param api_key [String]
    def initialize(api_key)
      @api_key = api_key
    end

    # Perform a GraphQL Query and return the result
    # @param query [String] GraphQL Query
    # @return [Net::HTTPResponse]
    def query(query)
      uri = URI("https://api.github.com/graphql")
      req = Net::HTTP::Post.new(uri)
      req["Authorization"] = "Bearer #{@api_key}"
      req["Content-Type"] = "application/json"
      req.body = {query: query}.to_json

      Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
        http.request(req)
      end
    end
  end
end
