require 'activesupport'

module Helpers
  def render_nav(options, exclude = nil)
    exclude = "Home" if (exclude == "Social")
    options.delete(exclude)
    options.collect do |name, url|
      ["<li class='nav-element' id='#{name.gsub(" ", "-")}'>",
       link_to(name, url),
       "</li>"].join
    end.join("\n")
  end
  
  def previous_link(post)
    label = ["&#8592;", h(post.title)].join(" ")
    link_to label, post.url
  end
  
  def next_link(post)
    label = [h(post.title), "&#8594;"].join(" ")
    link_to label, post.url
  end
  
  def published_date(time)
    time.strftime("Published on %A, %B %d, %Y")
  end
end