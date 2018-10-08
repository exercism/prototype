class Admin::MentorsController < ApplicationController

  def index
    @user_ids = TrackMentorship.distinct.pluck(:user_id)
    @users = User.where(id: @user_ids)
    @tracks = Hash.new
    @user_ids.each do |user_id|
      @tracks[user_id] = TrackMentorship.where(user_id: user_id).to_a().map {
        |mentorship|
        mentorship.track.title
      }
    end
  end

  def show
  end

end
