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

Exercism::MENTOR_RATING_THRESHOLD = 10
Exercism::MENTOR_ACTIVE_THRESHOLD = 1.month
Exercism::MEDIAN_MENTOR_RATING = 4.83

# To calculate median rating
=begin
def median(array)
  sorted = array.sort
  len = sorted.length
  (sorted[(len - 1) / 2] + sorted[len / 2]) / 2.0
end
rs = SolutionMentorship.where.not(rating: nil).group(:user_id).having("c > 4").select("user_id, COUNT(*) as c, AVG(rating) as r").map(&:r)
median(rs).to_f
=end
