class Git::SyncsTracks

  def self.sync
    new(Git::StateDb.instance).sync
  end

  attr_reader :state_db

  def initialize(state_db)
    @state_db = state_db
  end

  def sync
    puts "Syncing outstanding tracks"
    sync_outstanding
    ::Exercise.where(slug: "hello-world").update_all(auto_approve: true)
  end

  private

  def sync_outstanding
    loop do
      track = next_to_sync
      puts "Next track to sync: #{track.to_s}"
      break if track.nil?
      sync_one(track)
    end
  end

  def sync_one(track)
    puts "Sync track #{track.id}"
    begin
      Git::SyncsTrack.sync!(track)
    rescue => e
      puts e.message
      puts e.backtrace
    end
  end

  def next_to_sync
    next_job = state_db.stale_tracks_before.first
    return nil if next_job.nil?
    puts next_job
    Track.find(next_job[:track_id])
  rescue ActiveRecord::RecordNotFound => e
    state_db.delete_id(next_job[:track_id])
  end

end
