class SteamFetcher
  attr_reader :steam_user

  def initialize steam_user
    @steam_user = steam_user
  end

  def get_screenshots
    steam_url = "http://steamcommunity.com/id/#@steam_user/" +
                'screenshots/?appid=0&sort=newestfirst&' +
                'browsefilter=myfiles&view=grid'
    screenshots = []
    agent = Mechanize.new
    agent.get(steam_url) do |page|
      links = page.search('#image_wall .imageWallRow .profile_media_item')
      links.each do |link|
        details_url = link.attributes['href']
        image = link.at('img')
        description = link.at('.imgWallHoverDescription')
        title = description ? description.text.strip : nil
        medium_url = image.attributes['src'].to_s
        if medium_url =~ /\.resizedimage$/
          size_part = medium_url.split('/').last # e.g., 640x359.resizedimage
          full_size_url = medium_url.split(size_part).first
        else
          full_size_url = nil
        end
        latest_date = Time.now
        image_row = get_image_wall_row(link.parent)
        if image_row
          dates_container = get_image_row_dates_el(image_row)
          if dates_container
            date_range = dates_container.at('.image_grid_title').text.strip
            date_strs = date_range.split(' - ')
            dates = date_strs.map {|str|
              begin
                Date.parse(str)
              rescue
                nil
              end
            }
            latest_date = dates.last
          end
        end
        screenshots << Screenshot.new({
          details_url: details_url,
          title: title,
          medium_url: medium_url,
          date: latest_date,
          full_size_url: full_size_url
        })
      end
    end
    screenshots
  end

  private

  def get_image_wall_row current_node
    return unless current_node
    css_class = current_node.attributes['class']
    if css_class && css_class.value.include?('imageWallRow')
      return current_node
    end
    get_image_wall_row current_node.parent
  end

  def get_image_row_dates_el current_node
    return unless current_node
    css_class = current_node.attributes['class']
    if css_class && css_class.value.include?('image_grid_dates')
      return current_node
    end
    get_image_row_dates_el current_node.previous
  end
end
