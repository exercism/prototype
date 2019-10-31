Rails.application.routes.draw do

  # ### #
  # API #
  # ### #
  namespace :api do
    scope :v1 do
      get "ping" => "ping#index"
      get "validate_token" => "validate_token#index"

      resource :cli_settings, only: [:show]
      resources :tracks, only: [:show]
      resources :solutions, only: [:show, :update] do
        collection do
          get :latest
        end

        get 'files/*filepath', to: 'files#show', format: false, as: "file"
      end

      namespace :webhooks do
        resources :repo_updates, only: [:create]
        resources :contributors, only: [:create]
        resources :analyzers, only: [:create]
      end
    end
  end
  get "api/(*url)", to: 'api/base#render_404'

  # ### #
  # SPI #
  # ### #
  namespace :spi do
    get "exercise_fixtures/:track_slug/:exercise_slug" => "exercise_fixtures#show", as: :exercise_fixture
  end

  # ##### #
  # Admin #
  # ##### #
  namespace :admin do
    resource :dashboard, only: [:show], controller: "dashboard"
    resource :users, only: [:show]
    resources :solutions, only: [:show] do
      resources :iterations, only: [:show]
    end
    resources :mentors, only: [:index]
    namespace :data do
      resources :tracks, only: [:index, :show] do
        resources :exercises, only: [:show]
      end
    end
  end

  # ############### #
  # Changelog admin #
  # ############### #

  namespace :changelog_admin do
    resources :entries do
      post :publish, on: :member
      post :unpublish, on: :member
    end

    resource :referenceables, only: [] do
      get :search, on: :collection
    end

    root to: "entries#index"
  end

  # ###### #
  # Mentor #
  # ###### #

  get "become-a-mentor" => "mentor/registrations#landing", as: :become_a_mentor
  namespace :mentor do
    get "/", to: redirect("mentor/dashboard")
    resource :registrations, only: [:new, :create]
    resource :configure, only: [:show, :update], controller: "configure"
    resource :dashboard, only: [:show], controller: "dashboard" do
      get :your_solutions
      get :next_solutions
      get :testimonials
    end
    resources :solutions, only: [:show] do
      member do
        patch :lock
        patch :approve
        patch :abandon
        patch :ignore
        patch :ignore_requires_action
      end
    end
    resources :discussion_posts, only: [:create]
    resource :exercise_notes, only: [:show, :new], controller: "exercise_notes"
    resources :analyses do
      patch :replay, on: :member
    end
  end

  # #### #
  # Auth #
  # #### #
  devise_for :users, controllers: {
    sessions: 'sessions',
    registrations: 'registrations',
    confirmations: 'confirmations',
    omniauth_callbacks: "omniauth_callbacks"
  }

  devise_scope :user do
    get "confirmations/required" => "confirmations#required", as: 'confirmation_required'
  end

  resource :onboarding, only: [:show, :update] do
    get "migrate_to_v2"
  end

  # ######## #
  # External #
  # ######## #
  resources :profiles, only: [:index, :show] do
    get :solutions, on: :member
  end

  resources :solutions, only: [:show] do
    resources :comments, controller: "solution_comments", only: [:show, :create, :update, :destroy]
  end

  resources :tracks, only: [:index, :show] do
    member do
      post :join
      get :mentors
      get :maintainers
    end
    resources :exercises, only: [:index, :show] do
      resources :solutions, only: [:index, :show]
    end
    resources :maintainers, only: [:index]
    resources :mentors, only: [:index]

    Git::ExercismRepo::PAGES.each do |page|
      get page => "track_pages##{page}", as: "#{page}_page"
    end
  end

  resources :changelog_entries, only: [:index, :show], param: :slug

  # ######## #
  # Internal #
  # ######## #
  namespace :my do
    resource :dashboard, only: [:show], controller: "dashboard"

    resources :tracks, only: [:index, :show] do
      resources :side_exercises, only: [:index]
    end

    resources :user_tracks, only: [:create] do
      member do
        patch :set_mentored_mode
        patch :set_independent_mode
        patch :pause
        patch :unpause
        delete :leave
      end
    end
    resources :solutions, only: [:index, :show, :create] do
      member do
        get :solve
        patch :submit

        get :walkthrough
        get :confirm_unapproved_completion
        patch :complete
        get :reflection
        patch :request_mentoring
        patch :cancel_mentoring_request
        patch :reflect
        patch :rate_mentors
        patch :publish
        patch :update_exercise

        patch :toggle_published
        patch :toggle_show_on_profile
        patch :toggle_allow_comments
      end

      resources :iterations, only: [:show]
    end
    resources :submissions, only: [] do
      get :test_results, on: :member
    end

    resources :starred_solutions, only: [:index, :create]

    resources :discussion_posts, only: [:create, :update, :destroy]
    resources :notifications, only: [:index] do
      patch :read, on: :member
      patch :read_batch, on: :collection
      get :all, on: :collection
    end
    resource :profile, controller: "profile"

    resource :settings do
      patch :reset_auth_token
      patch :cancel_unconfirmed_email
      patch :set_default_allow_comments

      get :confirm_delete_account
      delete :delete_account

      resource :preferences, only: [:edit, :update]
      resource :track_settings, only: [:edit, :update]
    end
  end

  # ##### #
  # Teams #
  # ##### #
  # namespace :teams do
  namespace :teams, path: '', constraints: { subdomain: 'teams' } do
    get "/" => "pages#index"
    get "dashboard" => "dashboard#index"

    resources :teams, only: [], param: :token do
      resource :join, controller: "teams/joins"
    end

    resources :invitations, only: [:show] do
      post :accept, on: :member
      post :reject, on: :member
    end

    resources :teams do
      patch :update_settings, on: :member

      resources :my_solutions, controller: "teams/my_solutions" do
        get :possible_exercises, on: :collection
      end
      resources :solutions, controller: "teams/solutions"
      resources :discussion_posts,
        only: [:create],
        controller: "teams/discussion_posts"
      resources :memberships,
        only: [:index, :destroy],
        controller: "teams/memberships"
      resources :invitations,
        only: [:new, :create, :destroy],
        controller: "teams/invitations"
    end

    Teams::PagesController::PAGES.values.each do |page|
      get page.to_s.dasherize => "pages##{page}"#, as: "teams_#{page}_page"
    end
  end

  # ##### #
  # Pages #
  # ##### #
  get "about" => "pages#about", as: 'about_page'
  get "supporters" => "pages#supporters", as: 'supporters_page'
  get "strategy" => "pages#strategy", as: 'strategy_page'
  %w{mozilla thalamus sloan}.each do |supporter|
    get "supporters/#{supporter}" => "pages#supporter_#{supporter}", as: "supporter_#{supporter}_page"
  end

  PagesController::PAGES.values.each do |page|
    get page.to_s.dasherize => "pages##{page}", as: "#{page}_page"
  end

  PagesController::HELP_PAGES.values.each do |page|
    get "help/#{page.to_s.dasherize}" => "pages##{page}", as: "#{page}_help_page"
  end

  PagesController::LICENCES.values.each do |licence|
    get "licences/#{licence.to_s.dasherize}" => "pages##{licence}", as: "#{licence}_licence"
  end

  get "cli-walkthrough" => "pages#cli_walkthrough", as: "cli_walkthrough_page"

  resource :team_page, only: [:show], path: "team" do
    get :staff
    get :maintainers
    get :contributors
    get :mentors
  end

  # #### #
  # Blog #
  # #### #
  resources :blog_posts, only: [:index, :show], path: "blog"
  resources :blog_comments, only: [:create, :update, :destroy]

  # ############ #
  # Unsubscribe  #
  # ############ #
  resource :unsubscribe, only: [:show, :update], controller: "unsubscribe"

  # ############ #
  # Weird things #
  # ############ #
  post "markdown/parse" => "markdown#parse"

  # ################ #
  # Legacy redirects #
  # ################ #
  get "submissions/:uuid" => "legacy_routes#submission_to_solution"


  constraints CanAccessFlipperUI do
    mount Flipper::UI.app(Flipper) => '/flipper'
  end

  root to: "pages#index"
end
