module GHX
  module Dependabot

    # A package is a dependency that is managed by a package manager. Referenced by a SecurityVulnerability.
    class Package
      attr_reader :ecosystem, :name

      def initialize(json_data)
        @ecosystem = json_data["ecosystem"]
        @name = json_data["name"]
      end
    end
  end
end
