Recaptcha.configure do |config|
  config.site_key  = ENV['RECAPTCHA_BBQ_SITE_KEY']
  config.secret_key = ENV['RECAPTCHA_BBQ_SECRET_KEY']
end
