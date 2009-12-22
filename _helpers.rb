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
end