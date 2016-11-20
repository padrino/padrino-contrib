RSpec::Matchers.define :have_selector do |selector, attributes|
  match do |actual|
    tags = html_matched_tags(actual, selector, attributes)
    tags.count > 0
  end

  def html_matched_tags(html, selector, attributes)
    dom = Oga.parse_html(html)

    selector = selector.to_s
    content_requirement = attributes.delete(:content)
    attributes.each do |name, value|
      selector += %{[#{name}="#{value}"]}
    end
    tags = dom.css(selector.to_s.gsub(/\[([^"']*?)=([^'"]*?)\]/, '[\1="\2"]'))
    if content_requirement
      tags = tags.select{ |tag| (tag.get('content') || tag.text).index(content_requirement) }
    end

    tags
  end
end

