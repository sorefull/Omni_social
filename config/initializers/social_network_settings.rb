class SocialNetworkSettings < Settingslogic
  source "#{Rails.root}/config/social_networks.yml"
  namespace Rails.env
end
