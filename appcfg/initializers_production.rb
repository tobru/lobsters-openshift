class << Rails.application
  def domain
    ENV['DOMAIN']
  end

  def name
    ENV['APP_TITLE']
  end
end

Rails.application.routes.default_url_options[:host] = Rails.application.domain
