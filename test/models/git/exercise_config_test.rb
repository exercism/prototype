require "test_helper"

module Git
  class ExerciseConfigTest < ActiveSupport::TestCase
    test "returns test messages" do
      config = Git::ExerciseConfig.new(
        tests: [{
          name: "OneWordWithOneVowel",
          cmd: "Sentence.WordWithMostVowels(\"a\")"
        }]
      )

      test_message = config.tests_info.first
      assert_equal "OneWordWithOneVowel", test_message.name
      assert_equal "Sentence.WordWithMostVowels(\"a\")", test_message.cmd
    end
  end
end
