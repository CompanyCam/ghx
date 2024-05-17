module GHX
  module Dependabot
    def self.get_alerts(owner:, repo:)
      GHX.rest_client.get("repos/#{owner}/#{repo}/dependabot/alerts?state=open&per_page=100").map do |alert|
        GHX::Dependabot::Alert.new(alert)
      end
    end
  end
end

require_relative "dependabot/alert"
require_relative "dependabot/package"
require_relative "dependabot/security_vulnerability"
