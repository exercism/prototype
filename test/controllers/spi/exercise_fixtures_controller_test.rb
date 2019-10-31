require_relative './test_base'

class SPI::ExerciseFixturesControllerTest < SPI::TestBase
  test "show fails without solution" do
    get spi_exercise_fixture_path(track_slug: "ruby", exercise_slug: "foo")
    assert_response 404
    actual = JSON.parse(response.body)
    assert_equal({}, actual)
  end

  test "show returns correctly interpolated fixture" do
    comments_markdown = "Something with a PLACEHOLDER_1 here."
    fixture = create :exercise_fixture, comments_markdown: comments_markdown

    get spi_exercise_fixture_path(
        track_slug: fixture.exercise.track.slug,
        exercise_slug: fixture.exercise.slug,
      ), {
        representation: fixture.representation,
        placeholder_mapping: { "PLACEHOLDER_1": "foobar"}
      }
    assert_response 200

    expected = {fixture: {
      status: fixture.status,
      comments_html: "<p>Something with a foobar here.</p>\n"
    }}
    actual = JSON.parse(response.body, symbolize_names: true)
    assert_equal(expected, actual)
  end
end
