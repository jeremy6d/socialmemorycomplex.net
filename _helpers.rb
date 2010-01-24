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
    time.strftime("Written by Jeremy Weiland on %A, %B %d, %Y")
  end
  
  def header(page)
    permalink = page.respond_to?(:url) ? page.url : ''
    title = page.title
    subtitle = "<span id='colon'>:</span> <div id='subtitle'>#{page.subtitle}</div>"  if page.respond_to? :subtitle
    "<a href='#{permalink}'>#{title}</a>#{subtitle}"
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
end