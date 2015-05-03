class SteamApp
  attr_reader :url, :screenshots_url, :name, :id

  def initialize data
    # e.g., http://steamcommunity.com/app/22330/screenshots/
    @url = data[:url]
    @name = data[:name]
    if @url
      app_prefix = 'steamcommunity.com/app/'
      app_prefix_index = @url.index(app_prefix)
      app_id_start = app_prefix_index + app_prefix.size
      app_id_end = @url.index('/', app_id_start)
      app_id_end ||= @url.size
      @id = @url[app_id_start...app_id_end]
      screenshot_prefix = '/screenshots'
      screenshot_index = @url.index(screenshot_prefix)
      if screenshot_index
        @screenshots_url = @url
        @url = @url[0...screenshot_index]
      end
    end
  end

  def to_hash
    {id: @id, name: @name, url: @url, screenshotsUrl: @screenshots_url}
  end
end
