# coding: utf-8
class GoogleWebSearch < GoogleSearch
  protected

  def process_results(response)
    web_results = response.items || []
    coder = HTMLEntities.new
    processed = web_results.collect do |result|
      title = enable_highlighting ? convert_highlighting(coder.decode(result.html_title)) : result.title
      content = enable_highlighting ? convert_highlighting(strip_br_tags(coder.decode(result.html_snippet))) : result.snippet
      Hashie::Rash.new({title: title, unescaped_url: result.link, content: content})
    end
    processed.compact
  end

  private

  def strip_br_tags(str)
    str.gsub(/<\/?br>/, '')
  end

  def convert_highlighting(str)
    str.gsub(/\u003cb\u003e/, "\uE000").gsub(/\u003c\/b\u003e/, "\uE001")
  end

end