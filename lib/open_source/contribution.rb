require 'json'
require 'forwardable'

class OpenSource::Contribution
  attr_reader :payload
  def initialize(payload)
    # Do an extra roundtrip via JSON so we don't have to deal with hashes.
    @payload = JSON.parse(payload.to_json, object_class: OpenStruct)
  end

  def complete?
    to_default_branch?
  end

  def to_default_branch?
    branch_name == payload.repository.default_branch
  end

  def username
    user.login
  end

  def github_id
    user.id
  end

  def avatar_url
    user.avatar_url
  end

  private

  def user
    payload.sender
  end

  def branch_name
    payload.ref.sub("refs/heads/", "")
  end
end
