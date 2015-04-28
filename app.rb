require 'rss'
require_relative 'screenshot'
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
  steam = SteamFetcher.new(steam_user)
  screenshots = steam.get_screenshots
  rss_url = request.url
  content_type 'application/atom+xml'
  SteamScreenshotRSS.new(steam_user, rss_url).make_rss(screenshots).to_s
end
