require 'set'
require 'ruby-debug'
require 'haml'
require 'active_support'

ARCHIVES_EXCERPT_CHAR_LIMIT = 150

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

      if self.is_haml?
        self.content = Haml::Engine.new(self.content, :format => :html5, :ugly => true).render(self, payload)
      end
      
      begin
        self.content = if self.is_haml? || hamlish?(self) #self.is_a?(Page) && (self.name.split(".").last == "haml")
          Haml::Engine.new(self.content, :format => :html5, :ugly => true).render(self, payload)
        else
          converter.convert(self.content) 
        end
      rescue => e     
        puts "Exception: #{e.inspect}\n#{self.data.inspect}content\n"
        debugger
      end

      self.transform unless self.respond_to?(:name) && (self.name.split(".").last == "sass")
      
      # output keeps track of what will finally be written
      self.output = self.content

      # recursively render layouts
      layout = layouts[self.data["layout"]]
      used = Set.new([layout])

layout = nil if self.respond_to?(:name) && %w(sass xml).include?(self.name.split(".").last)
# - debugger if self.respond_to?(:name) && (self.name == "archives.haml")
      while layout
        begin
          payload = payload.deep_merge({"content" => self.output, "page" => layout.data})
          self.output = Haml::Engine.new(layout.content, :format => :html5, :ugly => true).render(self, payload)
        rescue => e

          debugger
          puts "#{e.inspect} in #{self}"
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
      label = ["&#8592;", title_for(post)].join(" ")
      link_to label, post.url
    end

    def next_link(post)
      label = [title_for(post), "&#8594;"].join(" ")
      link_to label, post.url
    end

    def published_date(time)
      return time if time.is_a?(String)
      time.strftime("Written on %A, %B %d, %Y")
    end

    def header(page)
      title = title_for page
      subtitle = ""
      unless page['subtitle'].nil? || page['subtitle'] == ""
        subtitle = "<span id='colon'>:</span> <span id='subtitle'>#{page['subtitle']}</span>"
      end
      "<a href='/'>#{title}</a>#{subtitle}"
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

    def abridge(html, permalink, para_count)
      paragraph_count = (para_count || 3).to_i
      text = html.gsub(/<h3>.*<\/h3>/, "")
      return text if ((text.size < 2000) || !text.include?("<p>")) && para_count.nil?

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
        post['wordpress_url']
      end

      return wp_url unless wp_url =~ /^http:\/\/blog\.6thdensity\.net/
      nil
    end

    def href_for(post)
      offsite_href(post) || post['url']
    rescue
      "/"
    end

    def xml_escape(input)
      CGI.escapeHTML(input)
    end

    def offsite_link(post)
      return nil unless href = offsite_href(post)
      "<a class=\"outside-link\" href=\"#{href}\">Read this article</a>"
    end
    
    def link_to text, href
      "<a href='#{href}'>#{text}</a>"
    end

    def hamlish? obj
      return false unless obj.respond_to?(:name)
      %w(haml xml).include?(obj.name.split(".").last)
    end

    def title_for obj
      title = case obj.class.to_s
      when "Jekyll::Post"
        obj.title
      else
        obj['title']
      end

      if title =~ /\d{18}/
        obj['date'].strftime("%A, %B %d, %Y")
      else
        title
      end
    end

    def title_or_excerpt post
      if post.data['title'] =~ /\d{18}/
        text = post.content.gsub(/<\/?[^>]*>/, "").gsub("\n", "")
        if text.size > ARCHIVES_EXCERPT_CHAR_LIMIT
          text[0,ARCHIVES_EXCERPT_CHAR_LIMIT] + "..."
        elsif blank?(text)
          title_for(post)
        else
          text[0,ARCHIVES_EXCERPT_CHAR_LIMIT]
        end
      else
        post.data['title']
      end
    end

    def blank?(string)
      string.gsub(/\s*/, "").empty?
    end
    
    def svg_logo
      %{
        <?xml version="1.0" encoding="UTF-8" standalone="no"?>
<!-- Created with Inkscape (http://www.inkscape.org/) -->

<svg
   xmlns:dc="http://purl.org/dc/elements/1.1/"
   xmlns:cc="http://creativecommons.org/ns#"
   xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
   xmlns:svg="http://www.w3.org/2000/svg"
   xmlns="http://www.w3.org/2000/svg"
   xmlns:sodipodi="http://sodipodi.sourceforge.net/DTD/sodipodi-0.dtd"
   xmlns:inkscape="http://www.inkscape.org/namespaces/inkscape"
   width="67"
   height="67"
   id="svg2"
   sodipodi:version="0.32"
   inkscape:version="0.48.1 r9760"
   sodipodi:docname="6thDensityLogo.svg"
   version="1.0">
  <defs
     id="defs4" />
  <sodipodi:namedview
     id="base"
     pagecolor="#ffffff"
     bordercolor="#666666"
     borderopacity="1.0"
     gridtolerance="10000"
     guidetolerance="10"
     objecttolerance="10"
     inkscape:pageopacity="0.0"
     inkscape:pageshadow="2"
     inkscape:zoom="1"
     inkscape:cx="231.56877"
     inkscape:cy="-83.369494"
     inkscape:document-units="px"
     inkscape:current-layer="layer1"
     inkscape:window-width="1440"
     inkscape:window-height="852"
     inkscape:window-x="0"
     inkscape:window-y="0"
     width="310px"
     height="160px"
     showgrid="false"
     inkscape:window-maximized="1"
     fit-margin-top="0"
     fit-margin-left="0"
     fit-margin-right="0"
     fit-margin-bottom="0" />
  <metadata
     id="metadata7">
    <rdf:RDF>
      <cc:Work
         rdf:about="">
        <dc:format>image/svg+xml</dc:format>
        <dc:type
           rdf:resource="http://purl.org/dc/dcmitype/StillImage" />
        <dc:title></dc:title>
      </cc:Work>
    </rdf:RDF>
  </metadata>
  <g
     inkscape:label="Layer 1"
     inkscape:groupmode="layer"
     id="layer1"
     transform="translate(-59.786885,579.64752)">
    <g
       id="g4440"
       transform="matrix(0.88407199,0,0,0.88407199,-254.95782,-772.45822)"
       inkscape:export-filename="/Users/jeremyweiland/Pictures/projects/6thdensity/6d_logo.png"
       inkscape:export-xdpi="90"
       inkscape:export-ydpi="90">
      <g
         id="g4472"
         transform="matrix(0.31907127,0,0,0.31907127,242.42224,148.5064)">
        <path
           style="font-size:medium;font-style:normal;font-variant:normal;font-weight:normal;font-stretch:normal;text-indent:0;text-align:start;text-decoration:none;line-height:normal;letter-spacing:normal;word-spacing:normal;text-transform:none;direction:ltr;block-progression:tb;writing-mode:lr-tb;text-anchor:start;baseline-shift:baseline;color:#000000;fill:#000000;fill-opacity:1;stroke:none;stroke-width:1.02861893;marker:none;visibility:visible;display:inline;overflow:visible;enable-background:accumulate;font-family:Sans;-inkscape-font-specification:Sans"
           d="m 468.89676,414.45697 c -0.10697,15.46776 -0.10938,31.22228 -0.1971,44.46813 -23.84986,-7.35973 -47.83823,-15.76943 -68.2603,-22.06156 l -41.82027,-58.55383 6.57216,-2.08223 39.3471,54.87217 56.8051,18.32941 -0.13785,-32.35119 -68.39426,-49.64153 c 2.21152,-0.72977 5.72718,-1.7441 7.91135,-2.54503 23.74913,17.19307 47.81341,34.87431 68.17427,49.56538 z"
           id="path4415"
           inkscape:connector-curvature="0"
           sodipodi:nodetypes="cccccccccccc" />
        <g
           id="g4466">
          <path
             sodipodi:nodetypes="cccccccccccc"
             inkscape:connector-curvature="0"
             id="path2867"
             d="m 428.18775,276.45943 c -9.00519,-12.57655 -18.26351,-25.32364 -25.97826,-36.09132 23.62089,-8.06445 47.97098,-15.36087 68.1912,-22.27422 l 68.25039,22.7897 -4.09309,5.54758 -64.08552,-21.26487 -56.73005,18.5604 19.12708,26.09163 84.51068,-0.0403 c -1.36021,1.8903 -3.60824,4.77736 -4.90449,6.70915 -29.31928,0.0499 -59.18047,-0.10988 -84.28794,-0.0274 z"
             style="font-size:medium;font-style:normal;font-variant:normal;font-weight:normal;font-stretch:normal;text-indent:0;text-align:start;text-decoration:none;line-height:normal;letter-spacing:normal;word-spacing:normal;text-transform:none;direction:ltr;block-progression:tb;writing-mode:lr-tb;text-anchor:start;baseline-shift:baseline;color:#000000;fill:#000000;fill-opacity:1;stroke:none;stroke-width:1.02861893;marker:none;visibility:visible;display:inline;overflow:visible;enable-background:accumulate;font-family:Sans;-inkscape-font-specification:Sans" />
          <path
             style="font-size:medium;font-style:normal;font-variant:normal;font-weight:normal;font-stretch:normal;text-indent:0;text-align:start;text-decoration:none;line-height:normal;letter-spacing:normal;word-spacing:normal;text-transform:none;direction:ltr;block-progression:tb;writing-mode:lr-tb;text-anchor:start;baseline-shift:baseline;color:#000000;fill:#000000;fill-opacity:1;stroke:none;stroke-width:1.02861893;marker:none;visibility:visible;display:inline;overflow:visible;enable-background:accumulate;font-family:Sans;-inkscape-font-specification:Sans"
             d="m 398.49764,360.40218 c -14.74377,4.67807 -29.72795,9.54419 -42.35261,13.55396 -0.37049,-24.95685 0.21479,-50.36988 -0.1118,-71.7368 l 42.76482,-57.86757 4.01123,5.60705 -40.02761,54.37775 0.12144,59.68896 30.72521,-10.12817 26.07691,-80.38689 c 1.37745,1.87777 3.42853,4.90792 4.86521,6.73769 -9.0127,27.89971 -18.39228,56.25001 -26.07247,80.15413 z"
             id="path3901"
             inkscape:connector-curvature="0"
             sodipodi:nodetypes="cccccccccccc" />
          <path
             style="font-size:medium;font-style:normal;font-variant:normal;font-weight:normal;font-stretch:normal;text-indent:0;text-align:start;text-decoration:none;line-height:normal;letter-spacing:normal;word-spacing:normal;text-transform:none;direction:ltr;block-progression:tb;writing-mode:lr-tb;text-anchor:start;baseline-shift:baseline;color:#000000;fill:#000000;fill-opacity:1;stroke:none;stroke-width:1.02861893;marker:none;visibility:visible;display:inline;overflow:visible;enable-background:accumulate;font-family:Sans;-inkscape-font-specification:Sans"
             d="m 542.42157,364.39179 c 14.67766,4.88154 29.66035,9.75225 42.2308,13.92886 -14.36953,20.40829 -29.78045,40.62384 -42.07538,58.10201 l -68.61118,21.67931 0.0506,-6.89394 64.34546,-20.46488 34.98604,-48.36076 -30.8104,-9.86597 -68.34689,49.70673 c -0.0107,-2.32879 0.11105,-5.98582 0.0243,-8.31059 23.69047,-17.27382 47.9426,-34.6965 68.20649,-49.52104 z"
             id="path4417"
             inkscape:connector-curvature="0"
             sodipodi:nodetypes="cccccccccccc" />
          <path
             sodipodi:nodetypes="cccccccccccc"
             inkscape:connector-curvature="0"
             id="path4419"
             d="m 517.16452,280.11311 c 9.17827,-12.45081 18.44049,-25.19506 26.29717,-35.85962 14.96901,19.97274 29.4329,40.87634 42.25628,57.97057 l -0.58377,71.95238 -6.54089,-2.17847 0.42059,-67.52016 -35.18254,-48.218 -18.90403,26.25368 26.15356,80.36198 c -2.21812,-0.70946 -5.65854,-1.95533 -7.89633,-2.59122 -9.10763,-27.86888 -18.18326,-56.31793 -26.02035,-80.17107 z"
             style="font-size:medium;font-style:normal;font-variant:normal;font-weight:normal;font-stretch:normal;text-indent:0;text-align:start;text-decoration:none;line-height:normal;letter-spacing:normal;word-spacing:normal;text-transform:none;direction:ltr;block-progression:tb;writing-mode:lr-tb;text-anchor:start;baseline-shift:baseline;color:#000000;fill:#000000;fill-opacity:1;stroke:none;stroke-width:1.02861893;marker:none;visibility:visible;display:inline;overflow:visible;enable-background:accumulate;font-family:Sans;-inkscape-font-specification:Sans" />
        </g>
      </g>
    </g>
    <flowRoot
       xml:space="preserve"
       id="flowRoot4490"
       style="font-size:40px;font-style:normal;font-weight:normal;line-height:125%;letter-spacing:0px;word-spacing:0px;fill:#000000;fill-opacity:1;stroke:none;font-family:Sans"><flowRegion
         id="flowRegion4492"><rect
           id="rect4494"
           width="104"
           height="43"
           x="661"
           y="150" /></flowRegion><flowPara
         id="flowPara4496" /></flowRoot>    <g
       id="g4502"
       transform="matrix(2.2065465,0,0,2.2065465,-820.18676,540.8671)">
      <g
         id="g4510" />
    </g>
  </g>
</svg>
      }
    end
  end
end