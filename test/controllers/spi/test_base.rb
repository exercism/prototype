require 'test_helper'

module SPI
  class TestBase < ActionDispatch::IntegrationTest
    def get(path, params={})
      headers = {'Authorization' => "Token token=#{Rails.application.secrets.spi_token}"}
      super(path, params: params, headers: headers, as: :json)
    end
  end
end

