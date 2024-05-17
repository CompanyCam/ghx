module GHX
  module Dependabot
    class Package
      attr_reader :ecosystem, :name

      def initialize(json_data)
        @ecosystem = json_data["ecosystem"]
        @name = json_data["name"]
      end
    end
  end
end
