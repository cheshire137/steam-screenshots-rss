# encoding: utf-8
require 'rubygems'
require 'mechanize'
require 'rss'
require_relative 'screenshot'
require_relative 'steam_fetcher'
require_relative 'steam_screenshot_rss'

steam_user = 'cheshire137'
rss_url = "#{steam_user}_steam_screenshots.rss"
steam = SteamFetcher.new(steam_user)
screenshots = steam.get_screenshots
rss = SteamScreenshotRSS.new(steam_user, rss_url).make_rss(screenshots)

print "Content-type: application/atom+xml\r\n\r\n"
puts rss
