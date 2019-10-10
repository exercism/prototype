class ChangelogEntryForm
  def self.from_entry(entry)
    new(
      id: entry.id,
      title: entry.title,
      details_markdown: entry.details_markdown,
      referenceable_gid: entry.referenceable_gid,
      info_url: entry.info_url,
      created_by: entry.created_by,
      tweet: entry.tweet,
    )
  end

  include ActiveModel::Model

  validates :title, presence: true
  validates :created_by, presence: true
  validate :tweet_is_valid, if: :save_tweet?

  attr_accessor(
    :id,
    :title,
    :details_markdown,
    :referenceable_gid,
    :info_url,
    :created_by,
    :tweet_copy,
    :tweet,
  )

  def tweet
    @tweet ||= new_tweet

    @tweet.tap { |tweet| tweet.assign_attributes(copy: tweet_copy) }
  end

  def save
    ActiveRecord::Base.transaction do
      entry.save
      tweet.save if save_tweet?
    end
  end

  def referenceable_types
    [Track, Exercise.includes(:track)].
      map { |type| ChangelogEntry::ReferenceableType.new(type) }
  end

  def referenceable
    GlobalID::Locator.locate(referenceable_gid)
  end

  def entry
    return @entry if @entry

    @entry = id ? ChangelogEntry.find(id) : ChangelogEntry.new
    @entry.tap do |entry|
      entry.assign_attributes(
        title: title,
        details_markdown: details_markdown,
        details_html: details_html,
        referenceable: referenceable,
        referenceable_key: referenceable_key,
        info_url: info_url,
        created_by: created_by
      )
    end
  end

  private

  def save_tweet?
    tweet_copy.present?
  end

  def new_tweet
    ChangelogEntryTweet.new(entry: entry)
  end

  def details_html
    ParseMarkdown.(details_markdown)
  end

  def referenceable_key
    return if referenceable.blank?

    "#{referenceable.class.name.underscore}_#{referenceable.id}"
  end

  def tweet_is_valid
    errors.add(:tweet_copy, "is too long") unless tweet.valid?
  end
end
