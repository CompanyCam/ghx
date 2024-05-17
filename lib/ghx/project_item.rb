module GHX
  class ProjectItem
    attr_accessor :id, :project_id, :issue_number, :issue_title, :issue_url, :issue_state, :field_values, :field_map


    def initialize(field_configuration:, data:)
      _setup_field_configuration(field_configuration)

      GHX.logger.debug data

      node = data
      content = node["content"]

      # These are fields common to all Project Items:
      @id = node["id"]
      @project_id = node["project"]["id"]
      @issue_number = content["number"]
      @issue_title = content["title"]
      @issue_url = content["url"]
      @issue_state = content["state"]

      field_values = node["fieldValues"]["nodes"]

      field_values.each do |field|
        GHX.logger.debug "Field: #{field}"
        next unless field["field"]
        next if field["field"]["name"].to_s.empty?

        name = normalized_field_value_name(field["field"]["name"])

        self.public_send("#{name}=", extracted_field_value(field))
      rescue NoMethodError
        GHX.logger.warn "Could not find field name: #{field["field"]["name"]} in the field configuration for project item #{id}"
      end
    end

    # Updates the given fields to the given values. Makes a GraphQL call per field to do the update.
    #
    # @param fields [Hash] A hash of field names to values.
    def update(**fields)
      fields.each do |field, value|
        field_id = field_id(field)
        raise "Field not found: #{field}" unless field_id

        field_type = field_type(field)

        case field_type
        when "DATE"
          update_date_field(field_id, value)
        when "SINGLE_SELECT"
          update_single_select_field(field_id, value)
        when "TEXT"
          update_text_field(field_id, value)
        when "TITLE"
          update_title_field(field_id, value)
        else
          GHX.logger.warn "Unknown field type in update: #{field_type}"
        end

      end
    end

    def update_text_field(field_id, value)
      gql_query = <<~GQL
    mutation {
      updateProjectV2ItemFieldValue(input: {
        fieldId: "#{field_id}",
        itemId: "#{id}",
        projectId: "#{project_id}",
        value: { 
          text: "#{value}"
        }
      }) {
        projectV2Item {
          id  
        }
      }
    }
    GQL

      client = GraphqlClient.new(ENV["GITHUB_TOKEN"])
      res = client.query(gql_query)
      GHX.logger.debug "Update text field result"
      GHX.logger.debug res
    end

    def update_date_field(field_id, value)
      gql_query = <<~GQL
    mutation {
      updateProjectV2ItemFieldValue(input: {
        fieldId: "#{field_id}",
        itemId: "#{id}",
        projectId: "#{project_id}",
        value: { 
          date: "#{value}"
        }
      }) {
        projectV2Item {
          id  
        }
      }
    }
    GQL

      client = GraphqlClient.new(ENV["GITHUB_TOKEN"])
      res = client.query(gql_query)
      GHX.logger.debug "Update date field result"
      GHX.logger.debug res
    end

    def update_single_select_field(field_id, value)
      field_options = field_options(field_id)
      raise "No options found for #{field_id}" unless field_options

      option_id = field_options.find { |option| option[:name] == value }&.fetch(:id)
      raise "Option not found: #{value}" unless option_id

      gql_query = <<~GQL
    mutation {
      updateProjectV2ItemFieldValue(input: {
        fieldId: "#{field_id}",
        itemId: "#{id}",
        projectId: "#{project_id}",
        value: { 
          singleSelectOptionId: "#{option_id}"
        }
      }) {
        projectV2Item {
          id  
        }
      }
    }
    GQL

      client = GraphqlClient.new(ENV["GITHUB_TOKEN"])
      res = client.query(gql_query)
      GHX.logger.debug "Update single select field result"
      GHX.logger.debug res.body
    end

    private

    def _setup_field_configuration(field_configuration)
      @field_configuration = field_configuration.map{ |fc| fc.merge({normalized_name: normalized_field_value_name(fc[:name])})  }

      # Example field_configuration:
      # {:id=>"PVTF_lADOALH_aM4Ac-_zzgSxCno", :name=>"Title", :data_type=>"TITLE", :options=>nil}
      # {:id=>"PVTF_lADOALH_aM4Ac-_zzgSxCns", :name=>"Assignees", :data_type=>"ASSIGNEES", :options=>nil}
      # {:id=>"PVTF_lADOALH_aM4Ac-_zzgSzAZs", :name=>"Reported At", :data_type=>"DATE", :options=>nil}
      # {:id=>"PVTSSF_lADOALH_aM4Ac-_zzgSxCnw", :name=>"Status", :data_type=>"SINGLE_SELECT", :options=>[{:id=>"f971fb55", :name=>"To triage"}, {:id=>"856cdede", :name=>"Ready to Assign"}, {:id=>"f75ad846", :name=>"Assigned"}, {:id=>"47fc9ee4", :name=>"Fix In progress"}, {:id=>"5ef0dc97", :name=>"Additional Info Requested"}, {:id=>"98236657", :name=>"Done - Fixed"}, {:id=>"98aea6ad", :name=>"Done - Won't Fix"}, {:id=>"a3b4fc3a", :name=>"Duplicate"}, {:id=>"81377549", :name=>"Not a Vulnerability"}]}
      # {:id=>"PVTF_lADOALH_aM4Ac-_zzgSxCn0", :name=>"Labels", :data_type=>"LABELS", :options=>nil}
      # {:id=>"PVTF_lADOALH_aM4Ac-_zzgSxCn4", :name=>"Linked pull requests", :data_type=>"LINKED_PULL_REQUESTS", :options=>nil}
      # {:id=>"PVTF_lADOALH_aM4Ac-_zzgSxCn8", :name=>"Milestone", :data_type=>"MILESTONE", :options=>nil}
      # {:id=>"PVTF_lADOALH_aM4Ac-_zzgSxCoA", :name=>"Repository", :data_type=>"REPOSITORY", :options=>nil}
      # {:id=>"PVTF_lADOALH_aM4Ac-_zzgSxCoM", :name=>"Reviewers", :data_type=>"REVIEWERS", :options=>nil}
      # {:id=>"PVTSSF_lADOALH_aM4Ac-_zzgSxCuA", :name=>"Severity", :data_type=>"SINGLE_SELECT", :options=>[{:id=>"79628723", :name=>"Informational"}, {:id=>"153889c6", :name=>"Low"}, {:id=>"093709ee", :name=>"Medium"}, {:id=>"5a00bbe7", :name=>"High"}, {:id=>"00e0bbaf", :name=>"Critical"}, {:id=>"fd986bd9", :name=>"Duplicate"}]}
      # {:id=>"PVTF_lADOALH_aM4Ac-_zzgSzBcc", :name=>"Reporter", :data_type=>"TEXT", :options=>nil}
      # {:id=>"PVTF_lADOALH_aM4Ac-_zzgSzBho", :name=>"Resolve By", :data_type=>"DATE", :options=>nil}
      # {:id=>"PVTSSF_lADOALH_aM4Ac-_zzgTKjOw", :name=>"Payout Status", :data_type=>"SINGLE_SELECT", :options=>[{:id=>"53c47c02", :name=>"Ready for Invoice"}, {:id=>"0b8a4629", :name=>"Payout in Process"}, {:id=>"5f356a58", :name=>"Payout Complete"}, {:id=>"368048ac", :name=>"Ineligible for Payout"}]}
      @field_configuration.each do |field|
        next unless field[:name]
        next if field[:name].to_s.empty?

        # Example
        # name = "Reported At"
        # instance variable will be `@reported_at`
        # attr_accessor will be `reported_at`
        name = normalized_field_value_name(field[:name])
        instance_variable_set(:"@#{name}", nil)
        self.class.attr_accessor name.to_sym
      end
    end

    def normalized_field_value_name(name)
      name.tr(" ", "_").downcase
    end

    # Extracts the value from the field based on the field's data type. Thank you GraphQL for making this totally asinine.
    def extracted_field_value(field)
      this_field_configuration = @field_configuration.find { |f| f[:name] == field["field"]["name"] }

      case this_field_configuration[:data_type]
      when "DATE"
        field["date"]
      when "SINGLE_SELECT"
        field["name"]
      when "TEXT"
        field["text"]
      when "TITLE"
        field["text"]
      else
        GHX.logger.warn "Unknown data type in extracted_field_value: #{this_field_configuration[:data_type]}"
      end
    end

    def field_id(normalized_field_name)
      field = @field_configuration.find { |f| f[:normalized_name] == normalized_field_name.to_s }
      field[:id] if field
    end

    def field_type(normalized_field_name)
      field = @field_configuration.find { |f| f[:normalized_name] == normalized_field_name.to_s }
      field[:data_type] if field
    end

    def field_options(field_id)
      field = @field_configuration.find { |f| f[:id] == field_id }
      field[:options] if field
    end

  end
end