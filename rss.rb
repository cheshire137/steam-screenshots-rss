# encoding: utf-8
require 'rubygems'
require 'mechanize'
require 'rss'

steam_user = 'cheshire137'
steam = SteamFetcher.new(steam_user)
screenshots = steam.get_screenshots
rss = SteamScreenshotRSS.new(steam_user).make_rss(screenshots)

print "Content-type: application/atom+xml\r\n\r\n"
puts rss
