require "minitest/autorun"
require "ghx"

class CoreTest < Minitest::Test
  def test_that_code_loads
    GHX::Issue.new(owner: "test", repo: "test", title: "test")
    GHX::Project.new("asdf1234")

    project_item_data = {
      "content" => {
        "id" => "asdf1234",
        "number" => "1234",
        "title" => "test",
        "url" => "http://example.com",
        "state" => "open"
      },
      "project" => {
        "id" => "asdf1234"
      },
      "fieldValues" => {
        "nodes" => []
      }
    }

    GHX::ProjectItem.new(field_configuration: [], data: project_item_data)

    assert true
  end
end
