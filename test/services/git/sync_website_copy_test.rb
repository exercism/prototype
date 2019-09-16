require_relative '../../test_helper'
require 'webmock/minitest'

class Git::SyncWebsiteCopyTest < ActiveJob::TestCase
  test "syncs mentors" do
    stub_request(:get, "https://api.github.com/users/kytrinyx").
      to_return(
        status: 200,
        body: {
          login: "",
          avatar_url: "",
          html_url: "ht",
          name: "",
          company: "",
          email: "",
          bio: ""
        }.to_json,
        headers: { "Content-Type" => "application/json" }
    )
    track = create(:track, slug: "go")

    Git::SyncWebsiteCopy.()

    mentor = Mentor.last
    assert_equal track, mentor.track
    assert_equal "Katrina Owen", mentor.name
    assert_equal "Link", mentor.link_text
    assert_equal "example.com", mentor.link_url
    assert_equal "avatar.png", mentor.avatar_url
    assert_equal "kytrinyx", mentor.github_username
  end
end
