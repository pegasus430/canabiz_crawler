# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path
# Rails.application.config.assets.paths << Emoji.images_path

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
Rails.application.config.assets.precompile += %w( age-verification.js )
Rails.application.config.assets.precompile += %w( article_help.js )
Rails.application.config.assets.precompile += %w( dispensary_product.js )
Rails.application.config.assets.precompile += %w( sticky.js )
Rails.application.config.assets.precompile += %w( endless_scroll.js )
Rails.application.config.assets.precompile += %w( jquery-1.12.1.min.js )
Rails.application.config.assets.precompile += %w( jquery.meanmenu.js )
Rails.application.config.assets.precompile += %w( jquery.meanmenu.min.js )
Rails.application.config.assets.precompile += %w( jquery.scrollUp.js )
Rails.application.config.assets.precompile += %w( jquery.sticky.js )
Rails.application.config.assets.precompile += %w( main.js )
Rails.application.config.assets.precompile += %w( user_page.js )

Rails.application.config.assets.precompile += %w( style.css.scss )