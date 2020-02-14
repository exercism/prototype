require 'test_helper'

class SubmissionTestRunResultTest < ActiveSupport::TestCase
  test "returns cmd" do
    test_info = stub(name: "test_a_name_given", cmd: "Test.add(1, 1)")

    submission_test = SubmissionTestRunResult.new(
      test_info,
      "name" => "test_a_name_given",
      "status" => "fail",
      "message" => "Expected: \"One for Alice, one for me.\"\n  Actual: \"One for Alice, ne for me.\""
    )

    assert_equal "Test.add(1, 1)", submission_test.cmd
  end

  test "returns text" do
    test_info = stub(name: "test_a_name_given", msg: "We tried running %{output}")

    submission_test = SubmissionTestRunResult.new(
      test_info,
      "name" => "test_a_name_given",
      "status" => "fail",
      "message" => "Failed test"
    )

    assert_equal "<p>We tried running </p><pre><code>Failed test</code></pre>\n",
      submission_test.text
  end

  test "returns expected value" do
    test_info = stub(expected: 10)

    submission_test = SubmissionTestRunResult.new(
      test_info,
      "name" => "test_a_name_given",
      "status" => "fail",
      "message" => "Failed test"
    )

    assert_equal 10, submission_test.expected
  end
end
