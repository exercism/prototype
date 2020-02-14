require "application_system_test_case"

module Research
  class TestCase < ApplicationSystemTestCase
    setup do
      @original_host = Capybara.app_host
      Capybara.app_host = SeleniumHelpers.research_host
    end

    teardown do
      Capybara.app_host = @original_host
    end
  end
end
