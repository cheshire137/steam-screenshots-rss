class SteamScreenshot
  attr_reader :details_url, :title, :medium_url, :date, :full_size_url

  def initialize data
    @details_url = data[:details_url]
    @date = data[:date]
    @title = data[:title] || @date.to_s
    @medium_url = data[:medium_url]
    @full_size_url = data[:full_size_url]
  end
end
