module GHX
  class Issue
    attr_accessor :owner, :repo, :number, :title, :body, :state, :state_reason, :author, :assignees, :labels, :milestone, :created_at, :updated_at, :closed_at

    def self.find(owner:, repo:, number:)
      response_data = GHX.rest_client.get("repos/#{owner}/#{repo}/issues/#{number}")
      new(owner: owner, repo: repo, **response_data)
    end

    def initialize(owner:, repo:, **args)
      @owner = owner
      @repo = repo
      update_attributes(args)
    end

    def save
      @number.nil? ? create : update
    end

    private

    def create
      response_data = GHX.rest_client.post("repos/#{owner}/#{repo}/issues", {
        title: @title,
        body: @body,
        labels: @labels,
        milestone: @milestone,
        assignees: @assignees
      })
      update_attributes(response_data)
      self
    end

    def update
      response_data = GHX.rest_client.patch("repos/#{owner}/#{repo}/issues/#{number}", {
        title: @title,
        body: @body,
        labels: @labels,
        milestone: @milestone,
        assignees: @assignees,
        state: @state,
        state_reason: @state_reason
      })
      update_attributes(response_data)
      self
    end

    def update_attributes(hash)
      self.number = hash["number"]
      self.title = hash["title"]
      self.body = hash["body"]
      self.state = hash["state"]
      self.state_reason = hash["state_reason"]
      self.labels = hash["labels"]
      self.milestone = hash["milestone"]
      self.assignees = hash["assignees"]
    end

  end
end