module API
  class TracksController < BaseController
    def show
      begin
        track = Track.find(params[:id])
      rescue
        return render json: {error: "Track not found", fallback_url: tracks_url}, status: 404
      end

      render json: {
        track: {
          id: track.slug,
          language: track.title,
          test_pattern: track.repo.test_pattern
        }
      }, status: 200
    end
  end
end
