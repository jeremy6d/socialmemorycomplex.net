require 'activesupport'

module Helpers
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
    title = page.title
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
    puts "paginator links"
    links = [if num = pages.previous_page
      link_to "&larr; Newer", (num == 1) ? "/" : "/page#{num}"
    end,
    
    unless pages.page < 2
      link_to "Home", "/"
    end,
    
    if num = pages.next_page
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

  def tags_for page
    if tags = page['tags']
      tags.join(", ")
    end
  end
end