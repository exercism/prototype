require 'test_helper'

class ExerciseFixtureTest < ActiveSupport::TestCase
  test "hash is created" do
    representation = "something goes here. it can be very long"
    fixture = create :exercise_fixture, representation: representation
    hash = OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha1'), "notverysecret", representation)
    assert_equal hash, fixture.representation_hash
  end

  test "lookup" do
    exercise = create :exercise
    representation = "some foobar"

    create :exercise_fixture, exercise: exercise
    create :exercise_fixture, representation: representation

    # Check all things are fulfilled
    assert_nil ExerciseFixture.lookup(exercise.track.slug, exercise.slug, representation)

    # Check the correct one is found
    fixture = create :exercise_fixture, exercise: exercise, representation: representation
    assert_equal fixture, ExerciseFixture.lookup(exercise.track.slug, exercise.slug, representation)
  end

  test "interpolate_comments_html" do
    markdown = "I really like your use of PLACEHOLDER_1 and your use of PLACEHOLDER_2, but espeically PLACEHOLDER_1."
    mapping = {"PLACEHOLDER_1" => "foobar", "PLACEHOLDER_2" => "barfoo"}
    expected = "<p>I really like your use of foobar and your use of barfoo, but espeically foobar.</p>\n"

    fixture = create :exercise_fixture, comments_markdown: markdown
    assert_equal expected, fixture.interpolated_comments(mapping)
  end

  test "interpolate_comments_html copes without placeholders" do
    markdown = "I really like your use of code"
    expected = "<p>I really like your use of code</p>\n"

    fixture = create :exercise_fixture, comments_markdown: markdown
    assert_equal expected, fixture.interpolated_comments(nil)
    assert_equal expected, fixture.interpolated_comments({})
    assert_equal expected, fixture.interpolated_comments({"PLACEHOLDER" => "bar"})
  end

end
