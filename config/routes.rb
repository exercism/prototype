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
      end
    end
  end
  get "api/(*url)", to: 'api#render_404'

  # ##### #
  # Admin #
  # ##### #
  namespace :admin do
    resource :dashboard, only: [:show], controller: "dashboard"
    resource :users, only: [:show]
    resources :solutions, only: [:show] do
      resources :iterations, only: [:show]
    end
  end

  # ###### #
  # Mentor #
  # ###### #
  namespace :mentor do
    get "/", to: redirect("mentor/dashboard")
    resource :configure, only: [:show, :update], controller: "configure"
    resource :dashboard, only: [:show], controller: "dashboard" do
      get :your_solutions
      get :next_solutions
    end
    resources :solutions, only: [:show] do
      member do
        patch :lock
        patch :approve
        patch :abandon
        patch :ignore
        get :report
        post :report, action: :report_send
      end
    end
    resources :discussion_posts, only: [:create]
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
  resources :solutions, only: [:show]
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
        post :leave
      end
    end
    resources :solutions, only: [:show, :create] do
      member do
        get :walkthrough
        get :confirm_unapproved_completion
        patch :complete
        get :reflection
        patch :request_mentoring
        patch :reflect
        patch :publish
        get :report
        post :report, action: :report_send
      end

      resources :iterations, only: [:show]
    end
    resources :reactions, only: [:index, :create]

    resources :discussion_posts, only: [:create, :update, :destroy]
    resources :notifications, only: [:index] do
      patch :read, on: :member
      patch :read_batch, on: :collection
    end
    resource :profile, controller: "profile"

    resource :settings do
      resource :communication_preferences, only: [:edit, :update]
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

    resources :invitations, only: [] do
      post :accept, on: :member
      post :reject, on: :member
    end

    resources :teams do
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
  PagesController::PAGES.values.each do |page|
    get page.to_s.dasherize => "pages##{page}", as: "#{page}_page"
  end

  get "cli-walkthrough" => "pages#cli_walkthrough", as: "cli_walkthrough_page"

  PagesController::LICENCES.values.each do |licence|
    get "licences/#{licence.to_s.dasherize}" => "pages##{licence}", as: "#{licence}_licence"
  end

  resource :team_page, only: [:show], path: "team" do
    get :maintainers
    get :mentors
    get :contributors
  end

  # ############ #
  # Weird things #
  # ############ #
  post "markdown/parse" => "markdown#parse"

  # ################ #
  # Legacy redirects #
  # ################ #
  get "submissions/:uuid" => "legacy_routes#submission_to_solution"

  root to: "pages#index"
end
