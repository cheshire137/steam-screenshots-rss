class SteamFetcher
  def self.get_screenshot_app details_url
    agent = Mechanize.new
    details = nil
    agent.get(details_url) do |page|
      link = page.search('.screenshotAppName a')[0]
      app_url = link.attributes['href'].to_s
      app_name = link.text.strip
      details = SteamApp.new(url: app_url, name: app_name)
    end
    details
  end

  def self.get_app_screenshots steam_app_id
    # e.g., http://steamcommunity.com/app/221100/screenshots/?p=1&browsefilter=mostrecent
    steam_url = "http://steamcommunity.com/app/#{steam_app_id}/" +
                'screenshots/?p=1&browsefilter=mostrecent'
    screenshots = []
    Mechanize.new.get(steam_url) do |page|
      cards = page.search('.apphub_Card')
      cards.each do |card|
        # e.g., ShowModalContent( 'http://steamcommunity.com/sharedfiles/filedetails/?id=433542054&insideModal=1', 'http://steamcommunity.com/sharedfiles/filedetails/?id=433542054', 'http://steamcommunity.com/sharedfiles/filedetails/?id=433542054',true );
        onclick = card.attributes['onclick'].to_s
        details_url = onclick.split("', '")[1]
        image = card.at('.apphub_CardContentPreviewImage')
        medium_url = image.attributes['src'].to_s
        full_size_url = get_full_size_url(medium_url)
        title = card.at('.apphub_CardMetaData .apphub_CardContentTitle').text.strip
        user_link = card.search('.apphub_CardContentAuthorBlock ' +
                                '.apphub_CardContentAuthorName a').last
        user_name = user_link.text.strip
        user_url = user_link.attributes['href'].to_s
        screenshots << SteamScreenshot.new(details_url: details_url,
                                           title: title, medium_url: medium_url,
                                           full_size_url: full_size_url,
                                           user_name: user_name,
                                           user_url: user_url)
      end
    end
    screenshots
  end

  def self.get_full_size_url medium_url
    if medium_url =~ /\.resizedimage$/
      size_part = medium_url.split('/').last # e.g., 640x359.resizedimage
      medium_url.split(size_part).first
    end
  end

  def self.get_user_screenshots steam_user
    # e.g., http://steamcommunity.com/id/cheshire137/screenshots/?appid=0&sort=newestfirst&browsefilter=myfiles&view=grid
    steam_url = "http://steamcommunity.com/id/#{steam_user}/" +
                'screenshots/?appid=0&sort=newestfirst&' +
                'browsefilter=myfiles&view=grid'
    screenshots = []
    Mechanize.new.get(steam_url) do |page|
      links = page.search('#image_wall .imageWallRow .profile_media_item')
      links.each do |link|
        details_url = link.attributes['href']
        image = link.at('img')
        description = link.at('.imgWallHoverDescription')
        title = description ? description.text.strip : nil
        medium_url = image.attributes['src'].to_s
        full_size_url = get_full_size_url(medium_url)
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
        screenshots << SteamScreenshot.new({
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

  def self.get_image_wall_row current_node
    return unless current_node
    css_class = current_node.attributes['class']
    if css_class && css_class.value.include?('imageWallRow')
      return current_node
    end
    get_image_wall_row current_node.parent
  end

  def self.get_image_row_dates_el current_node
    return unless current_node
    css_class = current_node.attributes['class']
    if css_class && css_class.value.include?('image_grid_dates')
      return current_node
    end
    get_image_row_dates_el current_node.previous
  end
end
