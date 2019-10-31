class ExerciseFixture < ApplicationRecord
  belongs_to :exercise
  belongs_to :comments_by, class_name: "User"

  before_create do
    self.representation_hash = self.class.hash_representation(representation)
  end

  def self.lookup(track_slug, exercise_slug, representation)
    # Guard against an empty representation
    return nil unless representation.present?

    find_by(
      exercise: Exercise.joins(:track).
                         find_by(
                           "exercises.slug": exercise_slug,
                           "tracks.slug": track_slug
                         ),
      representation_hash: hash_representation(representation)
    )
  end

  def interpolated_comments(placeholder_mapping)
    md = comments_markdown.to_s
    placeholder_mapping.each do |placeholder, name|
      md.gsub!(placeholder, name)
    end if placeholder_mapping.present?
    ParseMarkdown.(md)
  end

  private
  def self.hash_representation(representation)
    OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha1'), "notverysecret", representation)
  end
end
