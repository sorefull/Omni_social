# README
Rails app example with **Social Networks** authentication with **Devise** from [this tutorial](https://www.digitalocean.com/community/tutorials/how-to-configure-devise-and-omniauth-for-your-rails-application).
## Step by step:
### 1. Adding main gems to Gemfile
```
gem 'therubyracer'
gem 'devise'
gem 'omniauth'
```
### 2. Adding gem for our social network to Gemfile
```
gem 'omniauth-digitalocean'
gem 'omniauth-github'
```
### 3. Bundle it!
```
bundle install
```
### 4. Generate User by Devise
```
rails generate devise:install
rails generate devise User
rake db:migrate
```
### 5. Updaiting our User model
```
rails g migration AddColumnsToUsers provider uid
rake db:migrate
```
### 6. A bit of secure
* Create ```config/social_networks.yml``` for our secrets and keys:
```
development:
    facebook:
      key: 'FACEBOOK_KEY'
      secret: 'FACEBOOK_SECRET'
    github:
      key: 'GITHUB_KEY'
      secret: 'GITHUB_SECRET'
...
```
* Create ```config/initializers/social_network_settings.rb``` :
```
class SocialNetworkSettings < Settingslogic
    source "#{Rails.root}/config/social_networks.yml"
    namespace Rails.env
end
```

### 7. Updating out Devise initializer
In ```config/initializers/devise.rb``` add before last line:
```
Devise.setup do |config|
  config.omniauth :facebook, SocialNetworkSettings.facebook.key, SocialNetworkSettings.facebook.secret
  config.omniauth :github, SocialNetworkSettings.github.key, SocialNetworkSettings.github.secret, scope: 'user:email'
end
```
Scope comes from [this](https://developer.github.com/v3/oauth/#scopes)
### 8. Updating User model
```
devise :database_authenticatable, :registerable, :recoverable, :rememberable,
  :trackable, :validatable, :omniauthable, :omniauth_providers => [:digitalocean, :github]

  def self.from_omniauth(auth)
      where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
        user.provider = auth.provider
        user.uid = auth.uid
        user.email = auth.info.email
        user.password = Devise.friendly_token[0,20]
      end
  end
```
Actually we can get any information (not only email), from web application.
### 9. Adding routing
Add this o your ```config/routes.rb``` :
```
devise_for :users, :controllers => { :omniauth_callbacks => "callbacks" }
```
### 10. Creating callback controllers
Then, create a new file ```/app/controllers/callbacks_controller.rb```, and add this into it (each def for each network) :
```
class CallbacksController < Devise::OmniauthCallbacksController
    def facebook
        @user = User.from_omniauth(request.env["omniauth.auth"])
        sign_in_and_redirect @user
    end

    def github
        @user = User.from_omniauth(request.env["omniauth.auth"])
        sign_in_and_redirect @user
    end
end
```
### 11. Now you can serve your app
