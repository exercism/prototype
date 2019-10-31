module API
  class FilesController < BaseController
    def show
      begin
        @solution = SolutionBase.find_by_uuid!(params[:solution_id])
      rescue
        return render_solution_not_found
      end

      unless current_user.may_view_solution?(@solution)
        return render_403(:solution_not_accessible)
      end

      if @solution.iterations.last
        file = @solution.iterations.last.files.where(filename: params[:filepath]).first
        content = file.try(:file_contents)
      end

      unless content
        begin
          content = exercise_reader.read_file(params[:filepath])
        rescue
          return render_file_not_found
        end
      end

      # Should this be content.present? ie should we 404 on empty files?
      return render_file_not_found unless content

      render plain: content
    end

    private

    def render_file_not_found
      render_404(:file_not_found)
    end

    def exercise_reader
      @exercise_reader ||= Git::ExercismRepo.new(track_url).exercise(exercise_slug, @solution.git_sha)
    end

    def exercise
      @exercise ||= @solution.exercise
    end

    def exercise_slug
      @exercise_slug ||= @solution.exercise.slug
    end

    def track_url
      @track_url ||= exercise.track.repo_url
    end
  end
end
