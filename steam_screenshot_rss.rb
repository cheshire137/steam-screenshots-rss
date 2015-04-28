class SteamScreenshotRSS
  attr_reader :steam_user, :rss_url

  def initialize steam_user, rss_url
    @steam_user = steam_user
    @rss_url = rss_url
  end

  def make_rss screenshots
    RSS::Maker.make('atom') do |maker|
      maker.channel.author = @steam_user
      maker.channel.updated = Time.now.to_s
      maker.channel.about = @rss_url
      maker.channel.title = "#@steam_user Steam Screenshots"
      screenshots.each do |screenshot|
        maker.items.new_item do |item| # RSS::Maker::Atom::Feed::Items::Item
          item.link = screenshot.details_url
          item.title = screenshot.title
          item.updated = screenshot.date.to_s
          item.summary = screenshot.full_size_url || screenshot.medium_url
        end
      end
    end
  end
end
