require 'declarative_authorization'
Authorization::AUTH_DSL_FILES = Dir.glob("#{Rails.root.to_s}/vendor/plugins/*/config/authorization_rules.rb")