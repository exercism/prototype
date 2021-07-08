require 'test_helper'

class ToggleSolutionTest < ActiveSupport::TestCase
  test "publishes a solution correctly" do
    Timecop.freeze do
      solution = create :solution
      assert ToggleSolution.(solution)
      solution.reload

      assert_equal Time.current.to_i, solution.published_at.to_i
      assert solution.show_on_profile
      assert solution.allow_comments
    end
  end

  test "unpublishes a solution correctly" do
    solution = create :solution, published_at: Time.now - 1.day
    assert ToggleSolution.(solution)
    solution.reload

    refute solution.published?
  end
end
