Rails.application.config.session_store :cookie_store, key: '_exercism_session', domain: :all, tld_length: 2
#Rails.application.config.session_store :cookie_store, key: '_exercism_session', domain: {
#  production: '.exercism.io',
#  development: '.localhost:3000'
#}.fetch(Rails.env.to_sym, :all)
