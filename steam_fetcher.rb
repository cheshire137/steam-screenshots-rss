require 'date'

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
        medium_url = clean_url(image.attributes['src'].to_s)
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

  def self.clean_url url
    if url && (query_start=url.index('?'))
      url[0...query_start]
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
        description = link.at('.imgWallHoverDescription')
        title = description ? description.text.strip : nil
        screenshots << {title: title, details_url: details_url}
      end
    end
    screenshots[0...10].map {|basic_info|
      details = get_screenshot_details(basic_info[:details_url])
      SteamScreenshot.new(basic_info.merge(details))
    }
  end

  def self.get_screenshot_details details_url
    details = {}
    Mechanize.new.get(details_url) do |page|
      link = page.at('.actualmediactn a')
      details[:full_size_url] = link.attributes['href']
      img = link.at('img')
      details[:medium_url] = img.attributes['src']
      author = page.at('.creatorsBlock')
      details[:user_name] = author.at('.friendBlockContent').text.strip
      author_link = author.at('.friendBlockLinkOverlay')
      details[:user_url] = author_link.attributes['href']
      metadata = page.search('.detailsStatsContainerRight .detailsStatRight')
      date_el = metadata[1]
      details[:date] = parse_details_page_date(date_el.text.strip)
    end
    details
  end

  # e.g., Mar 2, 2014 @ 12:55pm
  # e.g., Jul 4 @ 1:17pm
  def self.parse_details_page_date raw_date_str
    if raw_date_str.include? ','
      format = '%b %d, %Y @ %l:%M%P'
    else
      format = '%b %d @ %l:%M%P'
    end
    DateTime.strptime(raw_date_str, format)
  end
end
