class MentorProfile < ApplicationRecord
  belongs_to :user

  def recalculate_stats!
    update(
      num_solutions_mentored: calculate_num_solutions_mentored,
      average_rating: calculate_average_rating
    )
  end

  private
  def calculate_num_solutions_mentored
    user.solution_mentorships.joins(:solution).
      where.not('solutions.completed_at': nil).
      where(Arel.sql("rating IS NULL OR rating >= 4")).count
  end

  def calculate_average_rating
    rating_arr = user.solution_mentorships.where.not(rating: nil).order(:rating).pluck(:rating)
    if rating_arr.empty?
      0.0
    else
      five_percent = (rating_arr.length * 0.05).round
      rating_arr.shift(five_percent)
      (rating_arr.sum.to_f / rating_arr.length).round(2)
    end
  end
end
