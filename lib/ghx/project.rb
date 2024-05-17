module GHX
  class Project
    attr_reader :id

    def initialize(id)
      @id = id
      @field_configuration = nil
    end

    def field_configuration
      @field_configuration ||= _fetch_field_configuration
    end

    def _fetch_field_configuration
      gql_query = <<~GQL
        query {
          node(id: "#{id}") {
            ... on ProjectV2 {  
              fields(first: 100) {  
                nodes { 
                  ... on ProjectV2Field {
                    id  
                    name
                    dataType
                  } 

                  ... on ProjectV2SingleSelectField {
                    id
                    name
                    dataType
                    options {  
                        id  
                        name  
                    }
                  }

                  ... on ProjectV2IterationField {
                    id  
                    name  
                    dataType
                  }


                }
              } 
            } 
          }
        } 
      GQL

      client = GraphqlClient.new(ENV["GITHUB_TOKEN"])
      res = client.query(gql_query)

      data = JSON.parse(res.body)

      data.dig("data", "node", "fields", "nodes").collect do |field|
        {
          id: field["id"],
          name: field["name"],
          data_type: field["dataType"],
          options: field["options"]&.map { |option| {id: option["id"], name: option["name"]} }
        }
      end
    end

    def find_item_by_id(item_id)
      #       gql_query = <<~GQL
      #       query {
      #         node(id: "#{id}") {
      #           ... on Issue {
      #             number
      #             title
      #             url
      #           }
      #         }
      #       }
      # GQL
      #
      #       client = GraphqlClient.new(ENV["GITHUB_TOKEN"])
      #       res = client.query(gql_query)
      #
      #       puts res.body
    end

    # In order to find an item by its issue number, we need to query the project items and filter by the issue number,
    # then return the first item that matches the project ID.
    def find_item_by_issue_number(number:, owner: "CompanyCam", repo: "Company-Cam-API")
      gql_query = <<~GQL
              query {
          repository(owner: "#{owner}", name: "#{repo}") {
            issue(number: #{number.to_i}) {
              id
              number
              title
              url
              body
              createdAt
              projectItems(first: 100) {
                nodes {
                  id
                  project {
                    id
                    databaseId
                  }
        content {
                          ... on Issue {
                            number
                            title
                            url
                            state
                            assignees(first: 10) {
                              nodes {
                                login
                              }
                            }
                          }
                        }
                        fieldValues(first: 30) {
                          nodes {
                            ... on ProjectV2ItemFieldSingleSelectValue {
                              field {
                                ... on ProjectV2SingleSelectField {
                                  name
                                }
                              }
                              name
                              id
                            }
                            ... on ProjectV2ItemFieldLabelValue {
                              labels(first: 20) {
                                nodes {
                                  id
                                  name
                                }
                              }
                            }
                            ... on ProjectV2ItemFieldTextValue {
                              text
                              id
                              updatedAt
                              creator {
                                url
                              }
                              field {
                                 ... on ProjectV2Field {
                                    id
                                    name
                                 }
                              }
                            }
                            ... on ProjectV2ItemFieldMilestoneValue {
                              milestone {
                                id
                              }
                            }
                            ... on ProjectV2ItemFieldRepositoryValue {
                              repository {
                                id
                                url
                              }
                            }
                            ... on ProjectV2ItemFieldDateValue {
                              date
                              field {
                                ... on ProjectV2FieldCommon {
                                  id
                                  name
                                }
                              }    
                            }
                          }
                        }
                }
              }
            }
          }
        }
      GQL

      client = GraphqlClient.new(ENV["GITHUB_TOKEN"])
      res = client.query(gql_query)

      data = JSON.parse(res.body)

      project_item_data = data.dig("data", "repository", "issue", "projectItems", "nodes").find { |node| node["project"]["id"] == id }

      ProjectItem.new(field_configuration: field_configuration, data: project_item_data)
    end

    def get_all_items
      gql_query = <<~GQL
        query {
          node(id: "#{id}") {
            ... on ProjectV2 {
              items(last: 100) {
                nodes {
                  id
                  content {
                    ... on Issue {
                      number
                      title
                      url
                      state
                      assignees(first: 10) {
                        nodes {
                          login
                        }
                      }
                    }
                  }
                  fieldValues(first: 20) {
                    nodes {
                      ... on ProjectV2ItemFieldSingleSelectValue {
                        field {
                          ... on ProjectV2SingleSelectField {
                            name
                          }
                        }
                        name
                        id
                      }
                      ... on ProjectV2ItemFieldLabelValue {
                        labels(first: 20) {
                          nodes {
                            id
                            name
                          }
                        }
                      }
                      ... on ProjectV2ItemFieldTextValue {
                        text
                        id
                        updatedAt
                        creator {
                          url
                        }
                        field {
                           ... on ProjectV2Field {
                              id
                              name
                           }
                        }
                      }
                      ... on ProjectV2ItemFieldMilestoneValue {
                        milestone {
                          id
                        }
                      }
                      ... on ProjectV2ItemFieldRepositoryValue {
                        repository {
                          id
                          url
                        }
                      }
                      ... on ProjectV2ItemFieldDateValue {
                        date
                        field {
                          ... on ProjectV2FieldCommon {
                            id
                            name
                          }
                        }    
                      }
                    }
                  }
                }
              }
            }
          }
        }
      GQL

      res = GraphqlClient.default.query(gql_query)

      data = JSON.parse res.body

      items = data["data"]["node"]["items"]["nodes"]

      items.map { ProjectItem.new(field_configuration: field_configuration, data: _1) }
    end
  end
end
