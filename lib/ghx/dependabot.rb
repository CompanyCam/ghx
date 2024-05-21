module GHX
  # Module for Dependabot-related classes and methods
  module Dependabot

    # Get Dependabot alerts for a given repository
    #
    # @note ONLY RETURNS THE FIRST 100 ALERTS
    # @param owner [String] the owner of the repository
    # @param repo [String] the repository name
    # @return [Array<GHX::Dependabot::Alert>] the alerts
    def self.get_alerts(owner:, repo:)
      # TODO: Add pagination to get all alerts in one go

      GHX.rest_client.get("repos/#{owner}/#{repo}/dependabot/alerts?state=open&per_page=100").map do |alert|
        GHX::Dependabot::Alert.new(alert)
      end
    end
  end
end

require_relative "dependabot/alert"
require_relative "dependabot/package"
require_relative "dependabot/security_vulnerability"
