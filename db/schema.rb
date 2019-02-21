# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2019_02_13_003121) do

  create_table "active_storage_attachments", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "auth_tokens", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "token", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "active", default: true, null: false
    t.index ["user_id", "active"], name: "index_auth_tokens_on_user_id_and_active"
    t.index ["user_id"], name: "fk_rails_0d66c22f4c"
  end

  create_table "blog_comments", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "blog_post_id", null: false
    t.bigint "user_id", null: false
    t.bigint "blog_comment_id"
    t.text "content", limit: 4294967295, null: false
    t.text "html", limit: 4294967295, null: false
    t.boolean "edited", default: false, null: false
    t.text "previous_content"
    t.boolean "deleted", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["blog_comment_id"], name: "fk_rails_de25ffa957"
    t.index ["blog_post_id"], name: "fk_rails_ccd98ed6ee"
    t.index ["user_id"], name: "fk_rails_a2e6f28c3a"
  end

  create_table "blog_posts", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "uuid", null: false
    t.string "slug", null: false
    t.string "category", null: false
    t.datetime "published_at", null: false
    t.string "title", null: false
    t.string "author_handle", null: false
    t.string "marketing_copy", limit: 280
    t.string "content_repository", null: false
    t.string "content_filepath", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "image_url"
    t.index ["published_at"], name: "index_blog_posts_on_published_at"
    t.index ["slug"], name: "index_blog_posts_on_slug", unique: true
  end

  create_table "communication_preferences", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.boolean "email_on_new_discussion_post", default: true, null: false
    t.boolean "email_on_new_discussion_post_for_mentor", default: true, null: false
    t.boolean "email_on_new_iteration_for_mentor", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "receive_product_updates", default: true, null: false
    t.boolean "email_on_solution_approved", default: true, null: false
    t.boolean "email_on_remind_mentor", default: true, null: false
    t.boolean "email_on_new_solution_comment_for_solution_user", default: true, null: false
    t.boolean "email_on_new_solution_comment_for_other_commenter", default: true, null: false
    t.index ["user_id"], name: "fk_rails_65642a5510"
  end

  create_table "contributors", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "github_username", null: false
    t.string "avatar_url", null: false
    t.integer "num_contributions", default: 0, null: false
    t.boolean "is_maintainer", default: false, null: false
    t.boolean "is_core", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "github_id", null: false
    t.index ["is_maintainer", "is_core", "num_contributions"], name: "main_find_idx"
  end

  create_table "discussion_posts", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "iteration_id", null: false
    t.bigint "user_id"
    t.text "content", limit: 4294967295, null: false
    t.text "html", limit: 4294967295, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "edited", default: false, null: false
    t.text "previous_content"
    t.boolean "deleted", default: false, null: false
    t.index ["iteration_id"], name: "fk_rails_f58a02b68e"
  end

  create_table "exercise_topics", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "exercise_id", null: false
    t.bigint "topic_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["exercise_id"], name: "fk_rails_0e58b87007"
    t.index ["topic_id"], name: "fk_rails_0e642b953e"
  end

  create_table "exercises", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "track_id", null: false
    t.bigint "unlocked_by_id"
    t.string "uuid", null: false
    t.string "slug", null: false
    t.string "dark_icon_url"
    t.string "turquoise_icon_url"
    t.string "white_icon_url"
    t.string "title", null: false
    t.boolean "core", default: false, null: false
    t.boolean "active", default: true, null: false
    t.boolean "auto_approve", default: false, null: false
    t.text "blurb"
    t.text "description"
    t.integer "difficulty", default: 1, null: false
    t.integer "length", default: 1, null: false
    t.integer "position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["track_id"], name: "fk_rails_a796d89c21"
    t.index ["unlocked_by_id"], name: "fk_rails_03ec4ffbf3"
  end

  create_table "friendly_id_slugs", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "slug", limit: 190, null: false
    t.integer "sluggable_id", null: false
    t.string "sluggable_type", limit: 50
    t.string "scope", limit: 190
    t.datetime "created_at"
    t.index ["slug", "sluggable_type", "scope"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope", unique: true
    t.index ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type"
    t.index ["sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_id"
    t.index ["sluggable_type"], name: "index_friendly_id_slugs_on_sluggable_type"
  end

  create_table "ignored_solution_mentorships", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "solution_id", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["solution_id"], name: "fk_rails_31331ef022"
    t.index ["user_id"], name: "fk_rails_7b8f6c3112"
  end

  create_table "iteration_files", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "iteration_id", null: false
    t.string "filename", null: false
    t.binary "file_contents", null: false
    t.text "file_contents_digest", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["iteration_id"], name: "fk_rails_56b435457f"
  end

  create_table "iterations", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "solution_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "solution_type", default: "Solution", null: false
    t.string "legacy_uuid"
    t.index ["solution_id"], name: "fk_rails_5d9f1bf4bd"
  end

  create_table "legacy_mentors", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "track_id", null: false
    t.string "github_username", null: false
    t.text "bio"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.string "name"
    t.string "avatar_url"
    t.string "link_text"
    t.string "link_url"
    t.index ["track_id"], name: "index_legacy_mentors_on_track_id"
  end

  create_table "maintainers", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "track_id", null: false
    t.bigint "user_id"
    t.string "name", null: false
    t.string "avatar_url", null: false
    t.string "github_username", null: false
    t.string "link_text"
    t.string "link_url"
    t.text "bio"
    t.boolean "visible", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "alumnus"
    t.index ["track_id"], name: "fk_rails_ed46fd11a4"
    t.index ["user_id"], name: "fk_rails_5b1168410c"
  end

  create_table "mentor_profiles", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.text "bio"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "average_rating", precision: 3, scale: 2
    t.integer "num_solutions_mentored", default: 0, null: false
    t.index ["user_id"], name: "fk_rails_9a3e3e5b86"
  end

  create_table "notifications", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "about_type"
    t.bigint "about_id"
    t.string "trigger_type"
    t.bigint "trigger_id"
    t.string "type"
    t.text "content"
    t.text "link"
    t.boolean "read", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "fk_rails_b080fb4855"
  end

  create_table "profiles", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "display_name", null: false
    t.string "twitter"
    t.string "website"
    t.string "github"
    t.string "linkedin"
    t.string "medium"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "bio"
    t.index ["user_id"], name: "fk_rails_e424190865"
  end

  create_table "repo_update_fetches", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.timestamp "completed_at"
    t.bigint "repo_update_id", null: false
    t.string "host", limit: 190, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["repo_update_id", "host"], name: "index_repo_update_fetches_on_repo_update_id_and_host", unique: true
    t.index ["repo_update_id"], name: "index_repo_update_fetches_on_repo_update_id"
  end

  create_table "repo_updates", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.timestamp "synced_at"
    t.string "slug", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "solution_comments", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "solution_id", null: false
    t.bigint "user_id", null: false
    t.text "content", limit: 4294967295, null: false
    t.text "html", limit: 4294967295, null: false
    t.boolean "edited", default: false, null: false
    t.text "previous_content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "deleted", default: false, null: false
  end

  create_table "solution_locks", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "solution_id", null: false
    t.bigint "user_id", null: false
    t.datetime "locked_until", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["solution_id"], name: "fk_rails_d2575804da"
    t.index ["user_id"], name: "fk_rails_7c200d25d8"
  end

  create_table "solution_mentorships", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "solution_id", null: false
    t.boolean "abandoned", default: false, null: false
    t.integer "rating"
    t.text "feedback"
    t.boolean "show_feedback_to_mentor"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "requires_action_since"
    t.datetime "mentor_reminder_sent_at"
    t.index ["solution_id"], name: "fk_rails_704ccdde73"
    t.index ["user_id"], name: "fk_rails_578676d431"
  end

  create_table "solution_stars", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "solution_id", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["solution_id", "user_id"], name: "index_solution_stars_on_solution_id_and_user_id", unique: true
    t.index ["user_id"], name: "index_solution_stars_on_user_id"
  end

  create_table "solutions", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "uuid", null: false
    t.bigint "exercise_id", null: false
    t.string "git_sha", null: false
    t.string "git_slug", null: false
    t.bigint "approved_by_id"
    t.datetime "downloaded_at"
    t.datetime "completed_at"
    t.datetime "published_at"
    t.datetime "last_updated_by_user_at"
    t.datetime "last_updated_by_mentor_at"
    t.integer "num_mentors", default: 0, null: false
    t.text "reflection"
    t.boolean "is_legacy", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "track_in_independent_mode", default: false, null: false
    t.datetime "mentoring_requested_at"
    t.boolean "independent_mode", default: false, null: false
    t.string "triaged_as"
    t.boolean "paused", default: false, null: false
    t.boolean "show_on_profile", default: false, null: false
    t.boolean "allow_comments", default: false, null: false
    t.integer "num_comments", limit: 2, default: 0, null: false
    t.integer "num_stars", limit: 2, default: 0, null: false
    t.index ["approved_by_id"], name: "fk_rails_4cc89d0b11"
    t.index ["approved_by_id"], name: "ihid-5"
    t.index ["completed_at"], name: "ihid-6"
    t.index ["exercise_id", "user_id"], name: "index_solutions_on_exercise_id_and_user_id", unique: true
    t.index ["last_updated_by_user_at"], name: "ihid-3"
    t.index ["num_mentors", "exercise_id", "user_id"], name: "fix-4"
    t.index ["num_mentors", "exercise_id"], name: "fix-2"
    t.index ["num_mentors", "last_updated_by_user_at"], name: "ihid-4"
    t.index ["num_mentors", "track_in_independent_mode", "created_at", "exercise_id"], name: "mentor_selection_idx_2"
    t.index ["num_mentors", "user_id", "exercise_id"], name: "fix-5"
    t.index ["num_mentors", "user_id"], name: "fix-3"
    t.index ["num_mentors"], name: "ihid-2"
    t.index ["user_id", "exercise_id", "num_mentors"], name: "fix-6"
    t.index ["user_id", "exercise_id"], name: "fix-1"
    t.index ["user_id"], name: "fk_rails_f83c42cef4"
    t.index ["uuid"], name: "index_solutions_on_uuid"
  end

  create_table "team_invitations", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "team_id", null: false
    t.bigint "invited_by_id", null: false
    t.string "email", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "token", null: false
    t.index ["invited_by_id"], name: "fk_rails_654806c772"
    t.index ["team_id", "email"], name: "index_team_invitations_on_team_id_and_email", unique: true
  end

  create_table "team_memberships", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "team_id", null: false
    t.bigint "user_id", null: false
    t.boolean "admin", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["team_id", "user_id"], name: "index_team_memberships_on_team_id_and_user_id", unique: true
    t.index ["team_id"], name: "fk_rails_61c29b529e"
    t.index ["user_id"], name: "fk_rails_5aba9331a7"
  end

  create_table "team_solutions", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "team_id", null: false
    t.string "uuid", null: false
    t.bigint "exercise_id", null: false
    t.string "git_sha", null: false
    t.string "git_slug", null: false
    t.boolean "needs_feedback", default: false, null: false
    t.boolean "has_unseen_feedback", default: false, null: false
    t.integer "num_iterations", default: 0, null: false
    t.datetime "downloaded_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["exercise_id"], name: "fk_rails_ba74ecfdce"
    t.index ["team_id"], name: "fk_rails_1c8d2e5b15"
    t.index ["user_id", "team_id", "exercise_id"], name: "index_team_solutions_on_user_id_and_team_id_and_exercise_id", unique: true
  end

  create_table "teams", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "name", null: false
    t.string "slug", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "description"
    t.string "token", null: false
    t.boolean "url_join_allowed", default: true, null: false
    t.index ["slug"], name: "index_teams_on_slug", unique: true
    t.index ["token"], name: "index_teams_on_token", unique: true
  end

  create_table "testimonials", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "track_id"
    t.string "headline", null: false
    t.text "content", null: false
    t.string "byline", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["track_id"], name: "fk_rails_c5eac2171d"
  end

  create_table "topics", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "name", null: false
    t.string "slug", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "track_mentorships", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "track_id", null: false
    t.string "handle"
    t.string "avatar_url"
    t.string "link_text"
    t.string "link_url"
    t.text "bio"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["track_id"], name: "fk_rails_4a81f96f88"
    t.index ["user_id", "track_id"], name: "index_track_mentorships_on_user_id_and_track_id", unique: true
    t.index ["user_id"], name: "fk_rails_283ecc719a"
  end

  create_table "tracks", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "slug", null: false
    t.string "title", null: false
    t.string "repo_url", null: false
    t.text "introduction", null: false
    t.text "code_sample", null: false
    t.string "syntax_highligher_language", null: false
    t.string "bordered_green_icon_url"
    t.string "bordered_turquoise_icon_url"
    t.string "hex_green_icon_url"
    t.string "hex_turquoise_icon_url"
    t.string "hex_white_icon_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "active", default: true, null: false
  end

  create_table "user_tracks", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "track_id", null: false
    t.boolean "anonymous", default: false, null: false
    t.string "handle"
    t.string "avatar_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "independent_mode"
    t.datetime "paused_at"
    t.index ["independent_mode"], name: "ihid-1"
    t.index ["track_id", "user_id"], name: "index_user_tracks_on_track_id_and_user_id", unique: true
    t.index ["user_id"], name: "fk_rails_99e944edbc"
  end

  create_table "users", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "name", null: false
    t.string "handle", limit: 190, null: false
    t.string "avatar_url"
    t.string "email", limit: 190, default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token", limit: 190
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "confirmation_token", limit: 190
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.string "provider"
    t.string "uid"
    t.boolean "admin", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "accepted_privacy_policy_at"
    t.datetime "accepted_terms_at"
    t.boolean "dark_code_theme", default: false, null: false
    t.boolean "default_allow_comments"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["handle"], name: "index_users_on_handle", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "auth_tokens", "users", name: "auth_tokens_ibfk_1"
  add_foreign_key "blog_comments", "blog_comments"
  add_foreign_key "blog_comments", "blog_posts"
  add_foreign_key "blog_comments", "users"
  add_foreign_key "communication_preferences", "users", name: "communication_preferences_ibfk_1"
  add_foreign_key "discussion_posts", "iterations", name: "discussion_posts_ibfk_1"
  add_foreign_key "exercise_topics", "exercises", name: "exercise_topics_ibfk_1"
  add_foreign_key "exercise_topics", "topics", name: "exercise_topics_ibfk_2"
  add_foreign_key "exercises", "exercises", column: "unlocked_by_id"
  add_foreign_key "exercises", "tracks"
  add_foreign_key "ignored_solution_mentorships", "solutions"
  add_foreign_key "ignored_solution_mentorships", "users"
  add_foreign_key "iteration_files", "iterations"
  add_foreign_key "legacy_mentors", "tracks"
  add_foreign_key "maintainers", "tracks"
  add_foreign_key "maintainers", "users"
  add_foreign_key "mentor_profiles", "users"
  add_foreign_key "notifications", "users"
  add_foreign_key "profiles", "users"
  add_foreign_key "repo_update_fetches", "repo_updates"
  add_foreign_key "solution_locks", "solutions"
  add_foreign_key "solution_locks", "users"
  add_foreign_key "solution_mentorships", "solutions"
  add_foreign_key "solution_mentorships", "users"
  add_foreign_key "solutions", "exercises"
  add_foreign_key "solutions", "users"
  add_foreign_key "solutions", "users", column: "approved_by_id"
  add_foreign_key "team_invitations", "teams"
  add_foreign_key "team_invitations", "users", column: "invited_by_id"
  add_foreign_key "team_memberships", "teams"
  add_foreign_key "team_memberships", "users"
  add_foreign_key "team_solutions", "exercises"
  add_foreign_key "team_solutions", "teams"
  add_foreign_key "team_solutions", "users"
  add_foreign_key "testimonials", "tracks"
  add_foreign_key "track_mentorships", "tracks"
  add_foreign_key "track_mentorships", "users"
  add_foreign_key "user_tracks", "tracks"
  add_foreign_key "user_tracks", "users"
end
