class SteamApp
  attr_reader :url, :name, :id

  def initialize data
    # e.g., http://steamcommunity.com/app/22330/screenshots/
    @url = data[:url]
    @name = data[:name]
    if @url
      prefix = 'steamcommunity.com/app/'
      prefix_index = @url.index(prefix)
      app_id_start = prefix_index + prefix.size
      app_id_end = @url.index('/', app_id_start)
      app_id_end ||= @url.size
      @id = @url[app_id_start...app_id_end]
    end
  end

  def to_hash
    {id: @id, name: @name, url: @url}
  end
end
