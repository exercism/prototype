require 'test_helper'

class SolutionsControllerTest < ActionDispatch::IntegrationTest
  test "maintainers should not have duplicates" do
    un1 = "duplicate"
    un2 = "singular"
    m1a = create :maintainer, github_username: un1
    m1b = create :maintainer, github_username: un1
    m2 = create :maintainer, github_username: un2

    get maintainers_team_page_path
    assert_response :success
    assert_equal 2, assigns(:maintainers).length
    assert_equal assigns(:maintainers).map(&:github_username).sort, [un1, un2].sort
  end

  test "mentors should not have duplicates" do
    skip # TODO
    un1 = "duplicate"
    un2 = "singular"
    m1a = create :mentor, github_username: un1
    m1b = create :mentor, github_username: un1
    m2 = create :mentor, github_username: un2

    get mentors_team_page_path
    assert_response :success
    assert_equal 2, assigns(:mentors).length
    assert_equal assigns(:mentors).map(&:github_username).sort, [un1, un2].sort
  end
end
