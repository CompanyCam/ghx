# frozen_string_literal: true

require_relative "lib/version"

Gem::Specification.new do |s|
  s.name = "ghx"
  s.version = GHX::VERSION
  s.summary = "Wrapper around some GitHub API calls"
  s.description = "An object oriented wrapper around some GitHub API calls that aren't covered by Octokit"
  s.authors = ["CompanyCam"]
  s.email = "jeff.mcfadden@companycam.com"
  s.license = "MIT"
  s.files = Dir.glob("lib/**/*")
  s.homepage = "https://github.com/companycam/ghx"

  s.add_dependency "octokit"
  s.add_dependency "faraday", "~> 2.9.0"
  s.add_dependency "faraday-retry", "~> 2.2.1"

  s.add_development_dependency "standardrb"
  s.add_development_dependency "debug"
  s.add_development_dependency "minitest"
end
