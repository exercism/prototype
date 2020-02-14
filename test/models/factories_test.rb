require_relative '../test_helper'

class Factories < ActiveSupport::TestCase
  FactoryBot.factories.map(&:name).each do |factory|
    test factory.to_s do
      RestClient.stubs(:post)
      create factory
    end
  end
end
