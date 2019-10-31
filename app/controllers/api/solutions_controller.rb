module API
  class SolutionsController < BaseController
    NUM_BYTES_IN_MEGABYTE = 1048576

    def show
      begin
        solution = SolutionBase.find_by_uuid!(params[:id])
      rescue
        return render_solution_not_found
      end

      unless current_user.may_view_solution?(solution)
        return render_solution_not_accessible
      end

      responder = SolutionResponder.new(solution, current_user)

      if current_user == solution.user
        solution.update(downloaded_at: Time.current)
      end

      render json: responder.to_hash
    end

    def latest
      if params[:team_id].present?
        begin
          team = Team.find(params[:team_id])
        rescue
          return render_404(:team_not_found, fallback_url: teams_url)
        end

        begin
          track = Track.find(params[:track_id])
        rescue
          return render_404(:track_not_found, fallback_url: tracks_url)
        end

        begin
          exercise = track.exercises.find(params[:exercise_id])
        rescue
          return render_404(:exercise_not_found, fallback_url: track_url(track))
        end

        solution = TeamSolution.where(user_id: current_user.id, team_id: team.id, exercise_id: exercise.id).last!
      else
        if params[:track_id].present?
          begin
            track = Track.find(params[:track_id])
          rescue
            return render_404(:track_not_found, fallback_url: tracks_url)
          end

          begin
            exercise = track.exercises.find(params[:exercise_id])
          rescue
            return render_404(:exercise_not_found, fallback_url: track_url(track))
          end

          begin
            solution = current_user.solutions.where(exercise_id: exercise.id).last!
          rescue
            if current_user.may_unlock_exercise?(exercise)
              solution = CreateSolution.(current_user, exercise)
            else
              if UserTrack.where(user: current_user, track: track).exists?
                return render_403(:solution_not_unlocked)
              else
                return render_403(:track_not_joined)
              end
            end
          end

        # No track id provided
        else
          solutions = current_user.solutions.joins(:exercise).where("exercises.slug": params[:exercise_id]).includes(exercise: :track)
          if solutions.size == 1
            solution = solutions.first

          elsif solutions.size > 1
            return render_error(400, :track_ambiguous, possible_track_ids: solutions.flat_map {|s|s.exercise.track.slug}.uniq)

          else
            exercises = Exercise.side.where(unlocked_by: nil).where(track_id: current_user.tracks).where(slug: params[:exercise_id]).includes(:track)
            if exercises.size == 1
              solution = CreateSolution.(current_user, exercises.first)
            elsif exercises.empty?
              return render_404(:exercise_not_found)
            elsif exercises.size > 1
              return render_error(400, :track_ambiguous, possible_track_ids: exercises.map{|e|e.track.slug}.uniq)
            end
          end
        end
      end

      responder = SolutionResponder.new(solution, current_user)
      solution.update(
        git_slug: solution.exercise.slug,
        git_sha: solution.track_head
      ) unless solution.downloaded?

      render json: responder.to_hash

      # Only set this if we've not 500'd
      solution.update(downloaded_at: Time.current)
    end

    def update
      begin
        solution = SolutionBase.find_by_uuid!(params[:id])
      rescue
        return render_solution_not_found
      end

      return render_solution_not_accessible unless solution.user_id == current_user.id

      params[:files].each do |file|
        if file.size.to_f > NUM_BYTES_IN_MEGABYTE
          return render_error(400, :file_too_large, "#{file.original_filename} is too large")
        end
      end

      begin
        CreateIteration.(solution, params[:files])
      rescue DuplicateIterationError
        return render_error(400, :duplicate_iteration)
      end

      render json: {}, status: 201
    end

    private

    def set_track
      @track = Track.find_by!(slug: params[:track_id])
    end

    def set_exercise
      @exercise = @track.exercises.find_by!(slug: params[:exercise_id])
    end
  end
end
