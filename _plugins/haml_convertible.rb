require 'set'
require 'ruby-debug'
require 'haml'
require 'active_support'

# Convertible provides methods for converting a pagelike item
# from a certain type of markup into actual content
#
# Requires
#   self.site -> Jekyll::Site
#   self.content
#   self.content=
#   self.data=
#   self.ext=
#   self.output=
module Jekyll
  module Convertible
    def do_layout(payload, layouts)
      info = { :filters => [Jekyll::Filters], :registers => { :site => self.site } }

      # render and transform content (this becomes the final content of the object)
      payload["pygments_prefix"] = converter.pygments_prefix
      payload["pygments_suffix"] = converter.pygments_suffix

      if self.respond_to?(:name) && self.name.split(".").last == "haml"
        self.content = Haml::Engine.new(self.content).render(self, payload)
      end
       
      begin
        self.content = if self.is_haml? #self.is_a?(Page) && (self.name.split(".").last == "haml")
          Haml::Engine.new(self.content).render(self, payload)
        else
          converter.convert(self.content) 
        end
      rescue => e     
        puts "Exception: #{e.inspect}\n#{self.data.inspect}\n"
      end

      self.transform unless self.respond_to?(:name) && (self.name.split(".").last == "sass")
      
      # output keeps track of what will finally be written
      self.output = self.content

      # recursively render layouts
      layout = layouts[self.data["layout"]]
      used = Set.new([layout])
layout = nil if self.respond_to?(:name) && self.name.split(".").last == "sass"
      while layout
        begin
          payload = payload.deep_merge({"content" => self.output, "page" => layout.data})
          self.output = Haml::Engine.new(layout.content).render(self, payload)
        rescue => e
          puts "#{e.inspect} in #{self.name}"
        end

        if layout = layouts[layout.data["layout"]]
          if used.include?(layout)
            layout = nil # avoid recursive chain
          else
            used << layout
          end
        end
      end
    end
    
    def render_nav(options, exclude = nil)
      exclude = "Home" if (exclude == "Social")
      exclude = "Selected Posts" if exclude == "Selected"
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
      return time if time.is_a?(String)
      time.strftime("Written on %A, %B %d, %Y")
    end

    def header(page)
      title = page['title']
      subtitle = "<span id='colon'>:</span> <div id='subtitle'>#{page.subtitle}</div>"  if page.respond_to? :subtitle
      "<a href='#{href_for(page)}'>#{title}</a>#{subtitle}"
    end

    def disqus_two
      %q{<script type="text/javascript">
      //<![CDATA[
      (function() {
      	var links = document.getElementsByTagName('a');
      	var query = '?';
      	for(var i = 0; i < links.length; i++) {
      	if(links[i].href.indexOf('#disqus_thread') >= 0) {
      		query += 'url' + i + '=' + encodeURIComponent(links[i].href) + '&';
      	}
      	}
      	document.write('<script charset="utf-8" type="text/javascript" src="http://disqus.com/forums/socialmemorycomplex/get_num_replies.js' + query + '"></' + 'script>');
      })();
      //]]>
      </script>}
    end

    def get_description(page)
      (page.description if page.respond_to?(:description)) || "A political economy of the soul"
    end

    def abridge(html, permalink, paragraph_count)
      paragraph_count = (paragraph_count || 3).to_i
      text = html.gsub(/<h3>.*<\/h3>/, "")
      return text if text.size < 2000 || !text.include?("<p>")
      paragraphs = text.split("</p>")[0..(paragraph_count - 1)]
      unless paragraphs.size < paragraph_count
        paragraphs << "<p><a href=\"#{permalink}\">Read more...</a></p>" 
      end

      paragraphs.join
    end

    def pagination_links(pages)
      links = [if num = pages['previous_page']
        link_to "&larr; Newer", (num == 1) ? "/" : "/page#{num}"
      end,
      
      unless pages['page'] < 2
        link_to "Home", "/"
      end,
      
      if num = pages['next_page']
        link_to "Older &rarr;", (num == 1) ? "/" : "/page#{num}"
      end].compact.collect { |markup| "<li>#{markup}</li>" }.join(" ")
      "<ul>#{links}</ul>"
    end

    def offsite_href(post)
      wp_url = if post.respond_to?(:wordpress_url)
        post.wordpress_url
      elsif post.respond_to?(:data)
        post.data["wordpress_url"]
      else
        nil
      end

      return wp_url unless wp_url =~ /^http:\/\/blog\.6thdensity\.net/
      nil
    end

    def href_for(post)
      offsite_href(post) || post.url
    rescue
      "/"
    end

    def offsite_link(post)
      return nil unless href = offsite_href(post)
      "<a class=\"outside-link\" href=\"#{href}\">Read this article</a>"
    end
    
    def link_to text, href
      "<a href='#{href}'>#{text}</a>"
    end
  end
end