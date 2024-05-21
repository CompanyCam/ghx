require "time"
require "net/http"
require "json"
require "octokit"

class Hash
  def symbolize_keys!
    keys.each do |key|
      self[key.to_sym] = delete(key)
    end
    self
  end
end

require_relative "version"
require_relative "ghx/graphql_client"
require_relative "ghx/rest_client"
require_relative "ghx/dependabot"
require_relative "ghx/issue"
require_relative "ghx/project"
require_relative "ghx/project_item"

# GitHub eXtended API Interface
#
# Extra classes to support more OO interfaces to the GitHub API. Wraps both the REST API and GraphQL API. Currently
# incomplete. Functionality has been built for our existing use-cases, but nothing else.
module GHX
  # Defaults to $stdout
  # @return [Logger]
  def self.logger
    @logger ||= Logger.new($stdout)
  end

  # @param logger [Logger]
  def self.logger=(logger)
    @logger = logger
  end

  # Internal octokit client.
  # API Key defaults to ENV["GITHUB_TOKEN"]
  # @return [Octokit::Client]
  def self.octokit
    @octokit ||= Octokit::Client.new(access_token: ENV["GITHUB_TOKEN"])
  end

  # @param octokit [Octokit::Client]
  # @return [Octokit::Client]
  def self.octokit=(octokit)
    @octokit = octokit
  end

  # Internal graphql client.
  # API Key defaults to ENV["GITHUB_TOKEN"]
  # @return [GHX::GraphqlClient]
  def self.graphql
    @graphql ||= GHX::GraphqlClient.new(ENV["GITHUB_GRAPHQL_TOKEN"])
  end

  # @param graphql [GHX::GraphqlClient]
  # @return [GHX::GraphqlClient]
  def self.graphql=(graphql)
    @graphql = graphql
  end

  # Internal graphql client.
  # API Key defaults to ENV["GITHUB_TOKEN"]
  # @return [GHX::RestClient]
  def self.rest_client
    @rest_client ||= GHX::RestClient.new(ENV["GITHUB_TOKEN"])
  end

  # @param rest_client [GHX::RestClient]
  # @return [GHX::RestClient]
  def self.rest_client=(rest_client)
    @rest_client = rest_client
  end
end
