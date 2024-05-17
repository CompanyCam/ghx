module GHX
  class GraphqlClient
    def initialize(api_key)
      @api_key = api_key
    end

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

    # @param [String] project_id
    # @param [GithubProjectItem] project_item
    # @param [DateTime] reported_at
    def update_project_item_reported_at(project_item_id:, reported_at:, project_id: GithubProject::MAIN_GH_PROJECT_ID)
      field_id = "PVTF_lADOALH_aM4Ac-_zzgSzAZs" # project_item.field_map["Reported At"]

      gql_query = <<~GQL
        mutation {
          updateProjectV2ItemFieldValue(input: {
            fieldId: "#{field_id}",
            itemId: "#{project_item_id}",
            projectId: "#{project_id}",
            value: { 
              date: "#{reported_at.to_date}"
            }
          }) {
            projectV2Item {
              id  
            }
          }
        }
      GQL

      query(gql_query)
    end

    def update_project_item_reported_by(project_item_id:, reported_by:, project_id: GithubProject::MAIN_GH_PROJECT_ID)
      field_id = "PVTF_lADOALH_aM4Ac-_zzgSzBcc" # project_item.field_map["Reporter"]

      gql_query = <<~GQL
        mutation {
          updateProjectV2ItemFieldValue(input: {
            fieldId: "#{field_id}",
            itemId: "#{project_item_id}",
            projectId: "#{project_id}",
            value: { 
              text: "#{reported_by}"
            }
          }) {
            projectV2Item {
              id  
            }
          }
        }
      GQL

      query(gql_query)
    end
  end
end
