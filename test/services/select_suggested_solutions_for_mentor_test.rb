require 'test_helper'

class SelectSuggestedSolutionsForMentorTest < ActiveSupport::TestCase
  test "respects triaged_as" do
    mentor = create(:user)
    mentored_track = create :track

    create :track_mentorship, user: mentor, track: mentored_track
    mentee = create_mentee([mentored_track])
    triaged_as = "status_1"

    solution1 = create(:solution,
                       exercise: create(:exercise, track: mentored_track),
                       user: mentee,
                       triaged_as: triaged_as,
                       mentoring_requested_at: Time.current)
    solution2 = create(:solution,
                       exercise: create(:exercise, track: mentored_track),
                       user: mentee,
                       triaged_as: "status_2",
                       mentoring_requested_at: Time.current)
    solution3 = create(:solution,
                       exercise: create(:exercise, track: mentored_track),
                       user: mentee,
                       triaged_as: triaged_as,
                       mentoring_requested_at: Time.current)
    create :iteration, solution: solution1
    create :iteration, solution: solution2
    create :iteration, solution: solution3


    assert_equal [solution1, solution2, solution3].sort, SelectSuggestedSolutionsForMentor.(mentor).sort
    assert_equal [solution1, solution3].sort, SelectSuggestedSolutionsForMentor.(mentor, triaged_as: triaged_as).sort
  end

  test "only selects solutions for tracks that you are mentoring" do
    mentor = create(:user)
    mentored_track1 = create :track
    mentored_track2 = create :track
    unmentored_track = create :track
    mentee = create_mentee([mentored_track1, mentored_track2, unmentored_track])

    solution1 = create(:solution,
                       exercise: create(:exercise, track: mentored_track1),
                       user: mentee,
                       mentoring_requested_at: Time.current)
    solution2 = create(:solution,
                       exercise: create(:exercise, track: mentored_track2),
                       user: mentee,
                       mentoring_requested_at: Time.current)
    solution3 = create(:solution,
                       exercise: create(:exercise, track: unmentored_track),
                       user: mentee,
                       mentoring_requested_at: Time.current)
    create :iteration, solution: solution1
    create :iteration, solution: solution2
    create :iteration, solution: solution3

    create :track_mentorship, user: mentor, track: mentored_track1
    create :track_mentorship, user: mentor, track: mentored_track2

    assert_equal [solution1, solution2].sort, SelectSuggestedSolutionsForMentor.(mentor).sort
  end

  test "does not select solutions you already mentor" do
    mentor, track = create_mentor_and_track
    mentee = create_mentee([track])

    bad_solution = create(:solution,
                          exercise: create(:exercise, track: track),
                          user: mentee,
                          mentoring_requested_at: Time.current)
    good_solution = create(:solution,
                           exercise: create(:exercise, track: track),
                           user: mentee,
                           mentoring_requested_at: Time.current)
    create :iteration, solution: good_solution
    create :iteration, solution: bad_solution
    create :solution_mentorship, user: mentor, solution: bad_solution

    assert_equal [good_solution].sort, SelectSuggestedSolutionsForMentor.(mentor).sort
  end

  test "does not select solutions claimed by a mentor" do
    mentor, track = create_mentor_and_track
    mentee = create_mentee([track])

    bad_solution = create(:solution,
                          exercise: create(:exercise, track: track),
                          user: mentee,
                          mentoring_requested_at: Time.current)
    good_solution1 = create(:solution,
                          exercise: create(:exercise, track: track),
                          user: mentee,
                          mentoring_requested_at: Time.current)
    good_solution2 = create(:solution,
                           exercise: create(:exercise, track: track),
                           user: mentee,
                           mentoring_requested_at: Time.current)

    create :iteration, solution: bad_solution
    create :iteration, solution: good_solution1
    create :iteration, solution: good_solution2

    # Lock with a differnet mentor
    create :solution_lock, solution: bad_solution, user: create(:user), locked_until: Time.now + 1.day

    # Lock with the same mentor
    create :solution_lock, solution: good_solution1, user: mentor, locked_until: Time.now + 1.day

    assert_equal [good_solution1, good_solution2], SelectSuggestedSolutionsForMentor.(mentor)
  end

  test "does not select solutions that haven't requested mentoring" do
    mentor, track = create_mentor_and_track
    mentee = create_mentee([track])

    bad_solution = create(:solution,
                          exercise: create(:exercise, track: track),
                          user: mentee,
                          mentoring_requested_at: nil)
    good_solution = create(:solution,
                           exercise: create(:exercise, track: track),
                           user: mentee,
                           mentoring_requested_at: Time.current)
    create :iteration, solution: good_solution
    create :iteration, solution: bad_solution

    assert_equal [good_solution].sort, SelectSuggestedSolutionsForMentor.(mentor).sort
  end

  test "filters by track" do
    mentor, track1 = create_mentor_and_track
    track2 = create :track
    create :track_mentorship, user: mentor, track: track2
    mentee = create_mentee([track1, track2])

    bad_solution = create(:solution,
                          exercise: create(:exercise, track: track2),
                          user: mentee,
                          mentoring_requested_at: Time.current)
    good_solution = create(:solution,
                           exercise: create(:exercise, track: track1),
                           user: mentee,
                           mentoring_requested_at: Time.current)
    create :iteration, solution: good_solution
    create :iteration, solution: bad_solution

    assert_equal [good_solution].sort, SelectSuggestedSolutionsForMentor.(mentor, filtered_track_ids: track1.id).sort
  end

  test "filters by exercise" do
    mentor, track = create_mentor_and_track
    mentee = create_mentee([track])

    bad_exercise = create(:exercise, track: track)
    good_exercise = create(:exercise, track: track)
    bad_solution = create(:solution,
                          exercise: bad_exercise,
                          user: mentee,
                          mentoring_requested_at: Time.current)
    good_solution = create(:solution,
                           exercise: good_exercise,
                           user: mentee,
                           mentoring_requested_at: Time.current)
    create :iteration, solution: good_solution
    create :iteration, solution: bad_solution

    assert_equal [good_solution].sort, SelectSuggestedSolutionsForMentor.(mentor, filtered_exercise_ids: good_exercise.id).sort
  end

  test "only selects solutions that have an iteration" do
    mentor, track = create_mentor_and_track
    mentee = create_mentee([track])

    bad_solution = create(:solution,
                          exercise: create(:exercise, track: track),
                          user: mentee,
                          mentoring_requested_at: Time.current)
    good_solution = create(:solution,
                           exercise: create(:exercise, track: track),
                           user: mentee,
                           mentoring_requested_at: Time.current)
    create :iteration, solution: good_solution

    assert_equal [good_solution].sort, SelectSuggestedSolutionsForMentor.(mentor).sort
  end

  test "does not select solutions with >=3 mentors" do
    mentor, track = create_mentor_and_track
    mentee = create_mentee([track])

    # Temporary change: >=3 to >=1
    # For >=3 mentors, change the values below to 1 and 0 respective
    bad_solution = create(:solution,
                          exercise: create(:exercise, track: track),
                          num_mentors: 1,
                          user: mentee,
                          mentoring_requested_at: Time.current)
    good_solution = create(:solution,
                           exercise: create(:exercise, track: track),
                           num_mentors: 0,
                           user: mentee,
                           mentoring_requested_at: Time.current)
    create :iteration, solution: good_solution
    create :iteration, solution: bad_solution

    assert_equal [good_solution].sort, SelectSuggestedSolutionsForMentor.(mentor).sort
  end

  test "does not select approved solutions" do
    mentor, track = create_mentor_and_track
    mentee = create_mentee([track])

    bad_solution = create(:solution,
                          exercise: create(:exercise, track: track),
                          approved_by: create(:user),
                          user: mentee,
                          mentoring_requested_at: Time.current)
    good_solution = create(:solution,
                           exercise: create(:exercise, track: track),
                           approved_by: nil,
                           user: mentee,
                           mentoring_requested_at: Time.current)
    create :iteration, solution: good_solution
    create :iteration, solution: bad_solution

    assert_equal [good_solution].sort, SelectSuggestedSolutionsForMentor.(mentor).sort
  end

  test "does not select completed solutions" do
    mentor, track = create_mentor_and_track
    mentee = create_mentee([track])

    bad_solution = create(:solution,
                          exercise: create(:exercise, track: track),
                          completed_at: DateTime.now - 1.minute,
                          user: mentee,
                          mentoring_requested_at: Time.current)
    good_solution = create(:solution,
                           exercise: create(:exercise, track: track),
                           completed_at: nil,
                           user: mentee,
                           mentoring_requested_at: Time.current)
    create :iteration, solution: good_solution
    create :iteration, solution: bad_solution

    assert_equal [good_solution].sort, SelectSuggestedSolutionsForMentor.(mentor).sort
  end

  test "does not select ignored solutions" do
    mentor, track = create_mentor_and_track
    mentee = create_mentee([track])

    bad_solution = create(:solution,
                          exercise: create(:exercise, track: track),
                          user: mentee,
                          mentoring_requested_at: Time.current)
    good_solution = create(:solution,
                           exercise: create(:exercise, track: track),
                           user: mentee,
                           mentoring_requested_at: Time.current)
    create :iteration, solution: good_solution
    create :iteration, solution: bad_solution
    create :ignored_solution_mentorship, solution: bad_solution, user: mentor

    assert_equal [good_solution].sort, SelectSuggestedSolutionsForMentor.(mentor).sort
  end

  test "puts exercises in standard mode first" do
    mentor = create(:user)
    mentee = create(:user)
    track = create(:track)
    create(:track_mentorship, user: mentor, track: track)

    standard_exercise = create(:exercise, track: track)
    standard_solution = create(:solution, 
                               exercise: standard_exercise, 
                               user: mentee, 
                               track_in_independent_mode: false,
                               mentoring_requested_at: Time.current)

    independent_exercise = create(:exercise, track: track)
    independent_solution = create(:solution,
                                  exercise: independent_exercise,
                                  user: mentee,
                                  track_in_independent_mode: true,
                                  mentoring_requested_at: Time.current)

    [standard_solution, independent_solution].each do |solution|
      create :iteration, solution: solution
    end

    expected = [standard_solution, independent_solution]
    actual = SelectSuggestedSolutionsForMentor.(mentor)
    assert_equal expected.map(&:id), actual.map(&:id)
  end

  test "puts core exercises first" do
    mentor, track = create_mentor_and_track
    mentee = create_mentee([track])

    side_solution = create(:solution,
                           exercise: create(:exercise, track: track, core: false),
                           user: mentee,
                           mentoring_requested_at: Time.current)
    core_solution = create(:solution,
                           exercise: create(:exercise, track: track, core: true),
                           user: mentee,
                           mentoring_requested_at: Time.current)
    [core_solution, side_solution].each do |solution|
      create :iteration, solution: solution
    end

    assert_equal(
      [core_solution, side_solution],
      SelectSuggestedSolutionsForMentor.(mentor)
    )
  end

  test "orders correctly" do
    Timecop.freeze do
      mentor, track = create_mentor_and_track
      independent_user = create :user
      mentored_user = create :user
      core_exercise = create(:exercise, track: track, core: true)
      side_exercise = create(:exercise, track: track, core: false)

      independent_solution = create(:solution,
                                    exercise: create(:exercise, track: track, core: true),
                                    num_mentors: 0,
                                    last_updated_by_user_at: DateTime.now,
                                    user: independent_user,
                                    track_in_independent_mode: true,
                                    mentoring_requested_at: Time.current)

      unmentored_core_solution = create(:solution,
                                        exercise: create(:exercise, track: track, core: true),
                                        num_mentors: 0,
                                        last_updated_by_user_at: DateTime.now - 1.minute,
                                        user: mentored_user,
                                        mentoring_requested_at: Time.current)

      unmentored_core_solution_2 = create(:solution,
                                        exercise: create(:exercise, track: track, core: true),
                                        num_mentors: 0,
                                        created_at: Exercism::V2_MIGRATED_AT,
                                        last_updated_by_user_at: DateTime.now,
                                        user: mentored_user,
                                        mentoring_requested_at: Time.current)

      unmentored_side_solution = create(:solution,
                                        exercise: create(:exercise, track: track, core: false),
                                        num_mentors: 0,
                                        last_updated_by_user_at: DateTime.now,
                                        user: mentored_user,
                                        mentoring_requested_at: Time.current)

      mentored_1_core_solution = create(:solution,
                                        exercise: create(:exercise, track: track, core: true),
                                        num_mentors: 1,
                                        last_updated_by_user_at: DateTime.now - 10.minutes,
                                        user: mentored_user,
                                        mentoring_requested_at: Time.current)

      mentored_2_core_solution = create(:solution,
                                        exercise: create(:exercise, track: track, core: true),
                                        num_mentors: 2,
                                        last_updated_by_user_at: DateTime.now,
                                        user: mentored_user,
                                        mentoring_requested_at: Time.current)

      unmentored_older_legacy_core_solution = create(:solution,
                                        exercise: create(:exercise, track: track, core: true),
                                        num_mentors: 0,
                                        created_at: Exercism::V2_MIGRATED_AT - 1.hour,
                                        last_updated_by_user_at: Time.now - 30.seconds,
                                        user: mentored_user,
                                        mentoring_requested_at: Time.current)

      unmentored_newer_legacy_core_solution = create(:solution,
                                        exercise: create(:exercise, track: track, core: true),
                                        num_mentors: 0,
                                        created_at: Exercism::V2_MIGRATED_AT - 1.hour,
                                        last_updated_by_user_at: Time.now + 30.seconds,
                                        user: mentored_user,
                                        mentoring_requested_at: Time.current)

      unmentored_legacy_side_solution = create(:solution,
                                        exercise: create(:exercise, track: track, core: false),
                                        num_mentors: 0,
                                        created_at: Exercism::V2_MIGRATED_AT - 1.hour,
                                        last_updated_by_user_at: Time.now + 30.seconds,
                                        user: mentored_user,
                                        mentoring_requested_at: Time.current)

      unmentored_dead_legacy_core_solution = create(:solution,
                                        exercise: create(:exercise, track: track, core: true),
                                        num_mentors: 0,
                                        created_at: Exercism::V2_MIGRATED_AT - 1.hour,
                                        last_updated_by_user_at: Exercism::V2_MIGRATED_AT - 1.hour,
                                        user: mentored_user,
                                        mentoring_requested_at: Time.current)

      old_unmentored_core_solution = create(:solution,
                                        exercise: create(:exercise, track: track, core: true),
                                        num_mentors: 0,
                                        last_updated_by_user_at: Time.now - 1.day,
                                        user: mentored_user,
                                        mentoring_requested_at: Time.current)

      [
        independent_solution,
        old_unmentored_core_solution,
        unmentored_core_solution,
        unmentored_side_solution,
        unmentored_older_legacy_core_solution,
        unmentored_newer_legacy_core_solution,
        mentored_1_core_solution,
        mentored_2_core_solution,
        unmentored_legacy_side_solution,
        unmentored_dead_legacy_core_solution,
        unmentored_core_solution_2
      ].each do |solution|
        create :iteration, solution: solution
      end

      expected = [
        old_unmentored_core_solution,
        unmentored_core_solution,
        unmentored_core_solution_2,
        unmentored_older_legacy_core_solution,
        unmentored_newer_legacy_core_solution,
        unmentored_side_solution,
        unmentored_legacy_side_solution,
        independent_solution,
        unmentored_dead_legacy_core_solution,

        # We are currently not showing any solutions
        # with >=1 mentor. Uncomment these again when/if
        # we change this back to >=3 mentors.
        #mentored_1_core_solution,
        #mentored_2_core_solution,
      ]
      actual = SelectSuggestedSolutionsForMentor.(mentor)

      assert_equal expected.map(&:id), actual.map(&:id)
    end
  end

  def create_mentor_and_track
    mentor = create :user
    track = create :track
    create :track_mentorship, user: mentor, track: track
    [mentor, track]
  end

  def create_mentee(tracks)
    mentee = create(:user)
    tracks.each { |track| create(:user_track, track: track, user: mentee) }

    mentee
  end
end
