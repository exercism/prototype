class TeamPagesController < ApplicationController
  def show
  end

  def maintainers
    @page = params[:page]
    @maintainers_last_updated_at = Maintainer.order('updated_at DESC').limit(1).pluck(:updated_at)[0].to_i
    @maintainers = Maintainer.visible.reorder(Arel.sql('LENGTH(bio) DESC')).
                                      page(@page).
                                      group(:github_username).
                                      per(40)
  end

  def mentors
    @page = params[:page]
    @mentors_last_updated_at = TrackMentorship.order('updated_at DESC').limit(1).pluck(:updated_at)[0].to_i

    # TODO - only show if they have enough ratings
    @mentors = User.active_mentors.
                    joins(:mentor_profile)
                    reorder(Arel.sql('average_rating DESC')).
                    page(@page).
                    per(40)
  end

  def contributors
    @page = params[:page]
    @last_updated_at = Contributor.order('updated_at DESC').limit(1).pluck(:updated_at)[0].to_i
    @contributors = Contributor.where.not(is_core: true).
                                where.not(is_maintainer: true).
                                order("num_contributions DESC").
                                page(@page).
                                per(40)
  end
end
