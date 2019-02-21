FactoryBot.define do
  factory :mentor_profile do
    user { create :user }
  end

  factory :solution_star do
    solution { create :solution }
    user { create :user }
  end
  factory :blog_comment do
    blog_post { create :blog_post }
    user { create :user }
    content { "foobar" }
    html { "<p>foobar</p>" }
  end

  factory :blog_post do
    uuid { SecureRandom.uuid }
    slug { "slug-#{SecureRandom.uuid}" }
    category { "category-#{SecureRandom.uuid}" }
    published_at { Time.current - 1.minute }
    title { "Some blog post" }
    author_handle { create(:user).handle }
    content_repository { "blog" }
    content_filepath { SecureRandom.uuid }
  end

  factory :solution_comment do
    solution { create :solution }
    user { create :user }
      content { "Hello. World!" }
      html { "<p>Hello. World!</p>" }
  end

  factory :solution_lock do
    solution { create :solution }
    user { create :user }
    locked_until { Time.current }
  end

  factory :team_invitation do
    team { create :team }
    invited_by { create :user }
    email { "someone@somewhere.com" }
  end

  factory :team_membership do
    team { create :team }
    user { create :user }
  end

  factory :team do
    name { "The best team" }
  end

  factory :team_solution do
    team { create :team }
    user { create :user }
    exercise { create :exercise }
    git_sha { SecureRandom.uuid }
    git_slug { SecureRandom.uuid }
  end

  factory :ignored_solution_mentorship do
    user { create :mentor }
    solution { create :solution }
  end

  factory :contributor do
    github_username { SecureRandom.uuid }
    sequence(:github_id)
    avatar_url { "asd.jpg" }
    num_contributions { 20 }
  end

  factory :testimonial do
    headline { "Love it" }
    content { "Wowowowowow!!!" }
    byline { "Nicky from the block" }
  end

  factory :iteration_file do
    iteration { create :iteration }
    filename { "foobar-#{SecureRandom.uuid}.rb"}
    file_contents { "something = :else" }
  end

  factory :maintainer do
    track { create :track }
    github_username { "iHiD" }
    name { "Jeremy Walker" }
    avatar_url { "http://website.com/somewhere.jpg" }
  end

  factory :exercise_topic do
    exercise { create :exercise }
    topic { create :topic }
  end

  factory :topic do
    slug { "foobar" }
  end

  factory :profile do
    user { create :user }
    display_name { user.name }
  end

  factory :communication_preferences do
    user { create :user }
  end

  factory :notification do
    user { create :user }
    type { :some_notification_type }
    content { "Foobar" }
    link { "http://barfoo.com" }
  end

  factory :track_mentorship do
    user { create :mentor }
    track { create :track }
  end

  factory :auth_token do
    user { create :user }
    token { SecureRandom.uuid }
  end

  factory :solution_mentorship do
    user { create :mentor }
    solution { create :solution }
  end

  factory :discussion_post do
    iteration { create :iteration }
    user { create :user }
    content { "Some comment here" }
    html { "<p>Some comment here</p>" }
  end

  factory :iteration do
    solution { create :solution }
  end

  factory :track do
    title { "Ruby" }
    slug { "ruby-#{SecureRandom.uuid}" }
    syntax_highligher_language { slug }
    introduction { "Master the Ruby language" }
    code_sample {%q{
      puts "Hello World"
    }}
    repo_url { "http://example.com/ruby-#{SecureRandom.uuid}.git" }
  end

  factory :exercise do
    track { create :track }
    uuid { SecureRandom.uuid }
    slug { "bob-#{SecureRandom.uuid}" }
    title { "Bob" }
    core { false }
    position { 1 }
  end

  factory :user do
    name { "Jeremy Walker #{SecureRandom.random_number}" }
    handle { SecureRandom.uuid }
    email { "jez.walker+#{SecureRandom.uuid}@gmail.com" }
    password { "foobar123" }

    factory :mentor do
      after(:create) do |user|
        create(:mentor_profile, user: user) unless user.mentor_profile
      end
    end

    factory :system_user do
      id { User::SYSTEM_USER_ID }
    end
  end

  factory :solution do
    user { create :user }
    exercise { create :exercise }
    git_sha { SecureRandom.uuid }
    git_slug { SecureRandom.uuid }
  end

  factory :user_track do
    user { create :user }
    track { create :track }
    independent_mode { false }
  end

  factory :repo_update do
    slug { "website-copy" }
  end

  factory :repo_update_fetch do
    repo_update { create(:repo_update) }
    host { |n| "host-#{n}" }
  end
end
