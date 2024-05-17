require 'time'
require 'net/http'
require 'json'
require 'octokit'

require_relative "version"
require_relative 'ghx/graphql_client'
require_relative 'ghx/rest_client'
require_relative 'ghx/dependabot'
require_relative 'ghx/issue'
require_relative 'ghx/project'
require_relative 'ghx/project_item'

# GitHub eXtended API Interface
#
# Extra classes to support more OO interfaces to the GitHub API. Wraps both the REST API and GraphQL API. Currently
# incomplete. Functionality has been built for our existing use-cases, but nothing else.
module GHX
  def self.logger
    @logger ||= Logger.new($stdout)
  end

  def self.logger=(logger)
    @logger = logger
  end

  def self.octokit
    @octokit ||= Octokit::Client.new(access_token: ENV["GITHUB_TOKEN"])
  end

  def self.octokit=(octokit)
    @octokit = octokit
  end

  def self.graphql
    @graphql ||= GHX::GraphqlClient.new(ENV["GITHUB_GRAPHQL_TOKEN"])
  end

  def self.graphql=(graphql)
    @graphql = graphql
  end

  def self.rest_client
    @rest_client ||= GHX::RestClient.new(ENV["GITHUB_TOKEN"])
  end

  def self.rest_client=(rest_client)
    @rest_client = rest_client
  end


end