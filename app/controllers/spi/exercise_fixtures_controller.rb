module SPI
  class ExerciseFixturesController < BaseController
    def show
      fixture = ExerciseFixture.lookup(
        params[:track_slug],
        params[:exercise_slug],
        params[:representation]
      )

      return render json: {}, status: 404 unless fixture

      render json: {
        fixture: {
          status: fixture.status,
          comments_html: fixture.interpolated_comments(params[:placeholder_mapping])
        }
      }
    end
  end
end
