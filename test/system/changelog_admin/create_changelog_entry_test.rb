require "application_system_test_case"

module ChangelogAdmin
  class CreateChangelogEntryTest < ApplicationSystemTestCase
    test "admin creates a changelog entry" do
      Flipper.enable(:changelog)
      track = create(:track, title: "Ruby")
      exercise = create(:exercise, track: track, title: "Hello world")
      admin = create(:user,
                     :onboarded,
                     may_edit_changelog: true,
                     name: "User 1")

      sign_in!(admin)
      visit new_changelog_admin_entry_path
      fill_in "Short", with: "New Exercise"
      fill_in "Details", with: "# We've added a new exercise!"
      select_option "Ruby - Hello world",
        selector: "#changelog_entry_form_referenceable_gid"
      fill_in "More info URL", with: "https://github.com/exercism"
      fill_in "Tweet copy", with: "Hello, world!"
      click_on "Save"

      assert_text "New Exercise"
      assert_text "# We've added a new exercise!"
      assert_text "Ruby - Hello world"
      assert_text "https://github.com/exercism"
      assert_text "Hello, world!"

      Flipper.disable(:changelog)
    end

    test "admin views errors when creating a changelog entry" do
      Flipper.enable(:changelog)
      track = create(:track, title: "Ruby")
      exercise = create(:exercise, track: track, title: "Hello world")
      admin = create(:user,
                     :onboarded,
                     may_edit_changelog: true,
                     name: "User 1")

      sign_in!(admin)
      visit new_changelog_admin_entry_path
      fill_in "Short", with: "   "
      fill_in "Details", with: "# We've added a new exercise!"
      select_option "Ruby - Hello world",
        selector: "#changelog_entry_form_referenceable_gid"
      fill_in "More info URL", with: "https://github.com/exercism"
      click_on "Save"

      assert_text "Title can't be blank"
      assert has_select?(
        "changelog_entry_form_referenceable_gid",
        selected: "Ruby - Hello world",
        visible: false
      )
      assert_field "Details", with: "# We've added a new exercise!"
      assert_field "More info URL", with: "https://github.com/exercism"

      Flipper.disable(:changelog)
    end
  end
end
