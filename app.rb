require 'rss'
require 'json'
require_relative 'steam_screenshot'
require_relative 'steam_app'
require_relative 'steam_fetcher'
require_relative 'steam_screenshot_rss'

configure do
  enable :cross_origin
end

options '*' do
  response.headers['Allow'] = 'HEAD,GET,PUT,POST,DELETE,OPTIONS'
  response.headers['Access-Control-Allow-Headers'] =
      'X-Requested-With, X-HTTP-Method-Override, Content-Type, Cache-Control, ' +
      'Accept'
  200
end

get '/' do
  steam_user = params['user'] || 'cheshire137'
  screenshots = SteamFetcher.get_screenshots(steam_user)
  rss_url = request.url
  content_type 'application/atom+xml'
  SteamScreenshotRSS.new(steam_user, rss_url).make_rss(screenshots).to_s
end

get '/app_for_screenshot.json' do
  # e.g., http://steamcommunity.com/sharedfiles/filedetails/?id=339375969
  details_url = params[:url]
  app = SteamFetcher.get_screenshot_app(details_url)
  content_type 'application/json'
  app.to_hash.to_json
end
