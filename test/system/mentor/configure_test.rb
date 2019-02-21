require "application_system_test_case"

class MentorConfigureTest < ApplicationSystemTestCase
  test "mentor chooses tracks" do
    user = create :mentor
    track_one = create(:track, title: "Ruby")
    track_two = create(:track, title: "Elm")
    track_three = create(:track, title: "Piet")

    sign_in!(user)

    visit mentor_configure_path
    assert_track_selections(not_selected: ["Ruby", "Elm", "Piet"])
    check "Ruby"
    click_on "Save settings"
    assert_equal user.mentored_tracks, [track_one]

    visit mentor_configure_path
    assert_track_selections(selected: ["Ruby"], not_selected: ["Elm", "Piet"])
    uncheck "Ruby"
    check "Elm"
    click_on "Save settings"
    user.reload
    assert_equal user.mentored_tracks, [track_two]

    visit mentor_configure_path
    assert_track_selections(selected: ["Elm"], not_selected: ["Ruby", "Piet"])

    uncheck "Elm"
    click_on "Save settings"
    user.reload
    assert_equal user.mentored_tracks, []

    visit mentor_configure_path
    assert_track_selections(not_selected: ["Elm", "Ruby", "Piet"])

  end

  def assert_track_selections(selected: [], not_selected: [])
    selected.each do |title|
      assert_equal true, find_field(title).checked?
    end
    not_selected.each do |title|
      assert_equal false, find_field(title).checked?
    end
  end
end
