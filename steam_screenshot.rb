class SteamScreenshot
  attr_reader :details_url, :title, :medium_url, :date, :full_size_url,
              :user_name, :user_url

  def initialize data
    @details_url = data[:details_url]
    @date = data[:date]
    @title = data[:title] || @date.to_s
    @medium_url = data[:medium_url]
    @full_size_url = data[:full_size_url]
    @user_name = data[:user_name]
    @user_url = data[:user_url]
  end

  def to_hash
    {detailsUrl: @details_url, date: @date, title: @title,
     mediumUrl: @medium_url, fullSizeUrl: @full_size_url, userName: @user_name,
     userUrl: @user_url}
  end
end
