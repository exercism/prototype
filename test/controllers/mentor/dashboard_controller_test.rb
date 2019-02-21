require 'test_helper'

class Mentor::DashboardControllerTest < ActionDispatch::IntegrationTest
  test "302 if not signed in" do
    get mentor_dashboard_url
    assert_response 302
  end

  test "302 unless mentor" do
    sign_in!
    get mentor_dashboard_url
    assert_response 302
    assert_redirected_to new_mentor_registrations_path
  end

  test "redirects_correctly if mentor" do
    user = create :mentor

    sign_in!(user)
    get mentor_dashboard_url
    assert_redirected_to your_solutions_mentor_dashboard_url
  end

  test "200 in your_solutions if mentor" do
    user = create :mentor

    sign_in!(user)
    get your_solutions_mentor_dashboard_url
    assert_response :success
    assert_correct_page "mentor-dashboard-page"
  end

  test "200 in your_solutions if mentor with solutions" do
    user = create :mentor
    Exercism::MENTOR_RATING_THRESHOLD.times {
      create :solution_mentorship, user: user, rating: 5
    }

    sign_in!(user)
    get your_solutions_mentor_dashboard_url
    assert_response :success
    assert_correct_page "mentor-dashboard-page"
  end


  test "200 in next_solutions if mentor" do
    user = create :mentor
    mentorship = create :track_mentorship, user: user

    sign_in!(user)
    get next_solutions_mentor_dashboard_url
    assert_response :success
    assert_correct_page "mentor-next-solutions-page"
  end

  test "redirects_to configure path without track" do
    user = create :mentor

    sign_in!(user)
    get next_solutions_mentor_dashboard_url
    assert_redirected_to mentor_configure_path
  end

  test "/mentor redirects to dashboard" do
    user = create :user
    create :track_mentorship, user: user

    sign_in!(user)
    get mentor_url
    assert_redirected_to mentor_dashboard_url
  end
end
