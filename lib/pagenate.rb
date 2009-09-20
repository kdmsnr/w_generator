class Pagenate < Array
  attr_reader :current_page, :per_page, :total_entries, :total_pages

  def initialize(page, per_page, total = nil)
    @current_page = page.to_i
    raise InvalidPage.new(page, @current_page) if @current_page < 1
    @per_page = per_page.to_i
    if @per_page < 1
      raise ArgumentError,
      "`per_page` setting cannot be less than 1 (#{@per_page} given)"
    end
    self.total_entries = total if total
  end

  def out_of_bounds?
    current_page > total_pages
  end

  def offset
    (current_page - 1) * per_page
  end

  def previous_page
    current_page > 1 ? (current_page - 1) : nil
  end

  def next_page
    current_page < total_pages ? (current_page + 1) : nil
  end

  def total_entries=(number)
    @total_entries = number.to_i
    @total_pages = (@total_entries / per_page.to_f).ceil
  end

  def replace(array)
    result = super
    if total_entries.nil? and length < per_page and
        (current_page == 1 or length > 0)
      self.total_entries = offset + length
    end
    result
  end

  def to_html
    html = ''
    if previous_page
      html << "<a href=\"/w/list?page=#{previous_page}\">prev</a>&nbsp;"
    else
      html << "prev"
    end
    (1..@total_pages).each do |i|
      if current_page != i
        html << "<a href=\"/w/list?page=#{i}\">#{i}</a>&nbsp;"
      else
        html << "<strong>#{i}</strong>&nbsp;"
      end
    end
    if next_page
      html << "<a href=\"/w/list?page=#{next_page}\">next</a>&nbsp;"
    else
      html << "next"
    end
    return html
  end
end
