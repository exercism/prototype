require 'application_system_test_case'

class FilterSolutionsTest < ApplicationSystemTestCase
  test "your solutions section does not show up if you do not mentor any" do
    track = create(:track)
    mentor = create(:mentor,
                    accepted_terms_at: Date.new(2016, 12, 25),
                    accepted_privacy_policy_at: Date.new(2016, 12, 25),
                    mentored_tracks: [track])

    sign_in!(mentor)
    visit your_solutions_mentor_dashboard_path
    refute_selector ".your-solutions"

    solution = create :solution, exercise: create(:exercise, track: track)
    create :solution_mentorship, user: mentor, requires_action_since: Time.current, solution: solution
    visit your_solutions_mentor_dashboard_path
    assert_selector ".your-solutions"
  end

  test "filters solutions by status" do
    track = create(:track)
    mentor = create(:mentor,
                    accepted_terms_at: Date.new(2016, 12, 25),
                    accepted_privacy_policy_at: Date.new(2016, 12, 25),
                    mentored_tracks: [track])
    hello_world = create(:exercise, track: track)
    solution = create(:solution,
                      exercise: hello_world,
                      completed_at: Date.new(2016, 12, 25))
    create(:iteration, solution: solution)
    create(:solution_mentorship,
           user: mentor,
           solution: solution,
           abandoned: false,
           requires_action_since: nil)

    sign_in!(mentor)
    visit your_solutions_mentor_dashboard_path
    select_option "Completed", selector: "#your_status"

    assert page.has_link?(href: mentor_solution_path(solution))
  end

  test "displays solutions requiring action by default" do
    track = create(:track)
    mentor = create(:mentor,
                    accepted_terms_at: Date.new(2016, 12, 25),
                    accepted_privacy_policy_at: Date.new(2016, 12, 25),
                    mentored_tracks: [track])
    hello_world = create(:exercise, track: track)
    action_required_solution = create(:solution,
                                      exercise: hello_world)
    completed_solution = create(:solution,
                                exercise: hello_world,
                                completed_at: Date.new(2016, 12, 25))
    create(:iteration, solution: action_required_solution)
    create(:iteration, solution: completed_solution)
    create(:solution_mentorship,
           user: mentor,
           solution: action_required_solution,
           abandoned: false,
           requires_action_since: Time.current)
    create(:solution_mentorship,
           user: mentor,
           solution: completed_solution,
           abandoned: false,
           requires_action_since: nil)

    sign_in!(mentor)
    visit your_solutions_mentor_dashboard_path

    assert page.has_link?(href: mentor_solution_path(action_required_solution))
    assert page.has_no_link?(href: mentor_solution_path(completed_solution))
  end

  test "filters solutions by track" do
    ruby = create(:track, title: "Ruby")
    cpp = create(:track, title: "C++")
    mentor = create(:mentor,
                    accepted_terms_at: Date.new(2016, 12, 25),
                    accepted_privacy_policy_at: Date.new(2016, 12, 25),
                    mentored_tracks: [ruby, cpp])
    hello_world_ruby = create(:exercise, track: ruby)
    solution_ruby = create(:solution, exercise: hello_world_ruby)
    hello_world_cpp = create(:exercise, track: cpp)
    solution_cpp = create(:solution, exercise: hello_world_cpp)
    create(:iteration, solution: solution_ruby)
    create(:solution_mentorship,
           user: mentor,
           solution: solution_ruby,
           requires_action_since: Time.current)
    create(:iteration, solution: solution_cpp)
    create(:solution_mentorship,
           user: mentor,
           solution: solution_cpp,
           requires_action_since: Time.current)

    sign_in!(mentor)
    visit your_solutions_mentor_dashboard_path
    select_option "Ruby", selector: "#your_track_id"

    assert page.has_link?(href: mentor_solution_path(solution_ruby))
    assert page.has_no_link?(href: mentor_solution_path(solution_cpp))
  end

  test "filters solutions by exercise" do
    ruby = create(:track, title: "Ruby")
    go = create(:track, title: "Go")
    mentor = create(:mentor,
                    accepted_terms_at: Date.new(2016, 12, 25),
                    accepted_privacy_policy_at: Date.new(2016, 12, 25),
                    mentored_tracks: [ruby, go])
    hello_world = create(:exercise, title: "Hello World", track: ruby)
    sorting = create(:exercise, title: "Sorting", track: ruby)
    hello_world_solution = create(:solution, exercise: hello_world)
    create(:iteration, solution: hello_world_solution)
    create(:solution_mentorship,
           user: mentor,
           solution: hello_world_solution,
           requires_action_since: Time.current)
    sorting_solution = create(:solution, exercise: sorting)
    create(:iteration, solution: sorting_solution)
    create(:solution_mentorship,
           user: mentor,
           solution: sorting_solution,
           requires_action_since: Time.current)

    sign_in!(mentor)
    visit your_solutions_mentor_dashboard_path
    select_option "Ruby", selector: "#your_track_id"
    select_option "Sorting", selector: "#your_exercise_id"

    assert page.has_link?(href: mentor_solution_path(sorting_solution))
    assert page.has_no_link?(href: mentor_solution_path(hello_world_solution))
  end

  test "autoselects your solutions when mentor has one track" do
    track = create(:track)
    mentor = create(:mentor,
                    accepted_terms_at: Date.new(2016, 12, 25),
                    accepted_privacy_policy_at: Date.new(2016, 12, 25),
                    mentored_tracks: [track])
    exercise1 = create(:exercise, title: "Exercise 1", track: track)
    exercise2 = create(:exercise, title: "Exercise 2", track: track)
    solution1 = create(:solution, exercise: exercise1, mentoring_requested_at: Time.current)
    solution2 = create(:solution, exercise: exercise2, mentoring_requested_at: Time.current)
    create(:iteration, solution: solution1)
    create(:solution_mentorship,
           user: mentor,
           solution: solution1,
           requires_action_since: Time.current)

    create(:iteration, solution: solution2)

    sign_in!(mentor)
    visit your_solutions_mentor_dashboard_path

    your_track_id = find("#your_track_id + .selectize-control .item")["data-value"]
    assert_equal your_track_id, track.id.to_s
    assert has_selector? '.your-solutions'
  end
end
