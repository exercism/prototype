require "test_helper"

class ChangelogEntryTest < ActiveSupport::TestCase
  test "#publish! sets the published_at time" do
    time = Time.utc(2016, 12, 25)
    entry = create(:changelog_entry)

    entry.publish!(time)

    assert_equal time, entry.published_at
  end

  test "#publish! raises an error when publishing an already published entry" do
    time = Time.utc(2016, 12, 25)
    entry = create(:changelog_entry, published_at: time)

    assert_raises ChangelogEntry::EntryAlreadyPublishedError do
      entry.publish!
    end
  end

  test "published? returns true if published_at is set" do
    entry = create(:changelog_entry, published_at: Time.new(2016, 12, 25))

    assert entry.published?
  end

  test "published? returns false if published_at isn't set" do
    entry = create(:changelog_entry, published_at: nil)

    refute entry.published?
  end

  test "#tweet! tweets a changelog entry" do
    tweet = build(:changelog_entry_tweet)
    referenceable = mock()
    ChangelogEntry::Referenceable.stubs(:for).returns(referenceable)
    entry = build(:changelog_entry, tweet: tweet)

    referenceable.expects(:tweet).with(tweet)

    entry.tweet!
  end

  test "#tweet_link_url returns link to entry if details are present" do
    entry = create(:changelog_entry,
                   details_html: "<p>New exercise!</p>",
                   title: "Hello, world!")

    assert_equal(
      "https://test.exercism.io/changelog_entries/hello-world-#{entry.id}",
      entry.tweet_link_url
    )
  end

  test "#tweet_link_url returns info URL if it is present and details are blank" do
    entry = create(:changelog_entry,
                   details_html: nil,
                   info_url: "https://exercism.io")

    assert_equal "https://exercism.io", entry.tweet_link_url
  end

  test "#tweet_link_url returns empty string if details are blank and info URL is blank" do
    entry = create(:changelog_entry)

    assert_equal "", entry.tweet_link_url
  end
end
