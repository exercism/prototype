require 'test_helper'

class TracksControllerTest < ActionDispatch::IntegrationTest
  test "index renders" do
    get tracks_url
    assert_response :success
    assert_correct_page "tracks-page"
  end

  test "show renders" do
    Track.any_instance.stubs(repo: repo_mock)
    get track_url(create :track)
    assert_response :success
    assert_correct_page "track-page"
  end

  test "maintainers renders" do
    Track.any_instance.stubs(repo: repo_mock)
    get maintainers_track_url(create :track)
    assert_response :success
    assert_correct_page "track-maintainers-page"
  end

  test "mentors renders" do
    Track.any_instance.stubs(repo: repo_mock)
    get mentors_track_url(create :track)
    assert_response :success
    assert_correct_page "track-mentors-page"
  end


end
