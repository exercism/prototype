require 'test_helper'

class RemindSolutionMentorshipTest < ActiveSupport::TestCase
  test "works with mentorship when mentor times-out" do
    Timecop.freeze do
      mentor = create :mentor
      mentorship = create :solution_mentorship, user: mentor

      DeliverEmail.expects(:call).with(mentor, :remind_mentor, mentorship.solution)
      RemindSolutionMentorship.(mentorship)

      mentorship.reload
      assert_equal Time.now.to_i, mentorship.mentor_reminder_sent_at.to_i
    end
  end

  test "doesn't do anything if the reminder has already been sent" do
    Timecop.freeze do
      mentor = create :mentor
      mentorship = create :solution_mentorship, user: mentor, mentor_reminder_sent_at: Time.now

      DeliverEmail.expects(:call).never
      RemindSolutionMentorship.(mentorship)
    end
  end
end

