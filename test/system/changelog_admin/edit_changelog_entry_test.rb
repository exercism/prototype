require "application_system_test_case"

module ChangelogAdmin
  class EditChangelogEntryTest < ApplicationSystemTestCase
    test "admin edits a changelog entry" do
      Flipper.enable(:changelog)
      admin = create(:user, :onboarded, may_edit_changelog: true)
      entry = create(:changelog_entry,
                     title: "New Exercise",
                     details_markdown: "# We've added a new exercise!",
                     info_url: "https://github.com/exercism",
                     created_by: admin)
      tweet = create(:changelog_entry_tweet, entry: entry, copy: "Hello")
      track = create(:track, title: "Ruby")
      create(:exercise, track: track, title: "Hello world")

      sign_in!(admin)
      visit edit_changelog_admin_entry_path(entry)

      fill_in "Short", with: "New Exercise - Hello world"
      fill_in "Details", with: "# We've added a new exercise named Hello world!"
      select_option "Ruby - Hello world",
        selector: "#changelog_entry_form_referenceable_gid"
      fill_in "More info URL", with: "https://github.com/exercism/hello-world"
      fill_in "Tweet copy", with: "Hello, world!"
      click_on "Save"

      assert_text "New Exercise - Hello world"
      assert_text "# We've added a new exercise named Hello world!"
      assert_text "Ruby - Hello world"
      assert_text "https://github.com/exercism/hello-world"
      assert_text "Hello, world!"

      Flipper.disable(:changelog)
    end

    test "admin see errors when editing a changelog entry" do
      Flipper.enable(:changelog)
      admin = create(:user, :onboarded, may_edit_changelog: true)
      entry = create(:changelog_entry, created_by: admin)

      sign_in!(admin)
      visit edit_changelog_admin_entry_path(entry)
      fill_in "Short", with: "  "
      click_on "Save"

      assert_text "Title can't be blank"

      Flipper.disable(:changelog)
    end

    test "site admin edits a changelog entry in behalf of another user" do
      Flipper.enable(:changelog)
      site_admin = create(:user, :onboarded, admin: true)
      entry = create(:changelog_entry,
                     title: "New Exercise",
                     details_markdown: "# We've added a new exercise!",
                     info_url: "https://github.com/exercism")
      track = create(:track, title: "Ruby")
      create(:exercise, track: track, title: "Hello world")

      sign_in!(site_admin)
      visit edit_changelog_admin_entry_path(entry)

      fill_in "Short", with: "New Exercise - Hello world"
      fill_in "Details", with: "# We've added a new exercise named Hello world!"
      select_option "Ruby - Hello world",
        selector: "#changelog_entry_form_referenceable_gid"
      fill_in "More info URL", with: "https://github.com/exercism/hello-world"
      click_on "Save"

      assert_text "New Exercise - Hello world"
      assert_text "# We've added a new exercise named Hello world!"
      assert_text "Ruby - Hello world"
      assert_text "https://github.com/exercism/hello-world"

      Flipper.disable(:changelog)
    end
  end
end
