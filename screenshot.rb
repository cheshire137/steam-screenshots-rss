class Screenshot
  attr_reader :details_url, :title, :medium_url, :date

  def initialize data
    @details_url = data[:details_url]
    @date = data[:date]
    @title = data[:title] || @date.to_s
    @medium_url = data[:medium_url]
  end
end
