module Exercism
  V2_MIGRATED_AT = Time.new(2018, 7, 13, 10, 1, 29, 0)
  JS_AND_ECMA_MERGED_AT = Time.new(2018, 8, 19, 22, 2, 39, 0)

  module Magic
    HandleRegexp = /^[a-zA-Z0-9-]+$/
  end
end

if Rails.env.production?
  Exercism::API_HOST = "https://api.exercism.io"
elsif Rails.env.test?
  Exercism::API_HOST = "https://test-api.exercism.io"
else
  Exercism::API_HOST = "http://lvh.me:3000/api"
end
