require 'rss'
require_relative 'screenshot'
require_relative 'steam_fetcher'
require_relative 'steam_screenshot_rss'

get '/' do
  steam_user = params['user'] || 'cheshire137'
  steam = SteamFetcher.new(steam_user)
  screenshots = steam.get_screenshots
  rss_url = request.url
  content_type 'application/atom+xml'
  SteamScreenshotRSS.new(steam_user, rss_url).make_rss(screenshots).to_s
end
