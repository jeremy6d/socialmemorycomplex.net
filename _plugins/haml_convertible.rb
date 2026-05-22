require "set"
require "haml"
require "active_support"
require "active_support/core_ext/string/output_safety"

ARCHIVES_EXCERPT_CHAR_LIMIT = 150

module Jekyll
  module HamlHelpers
    def html_safe_string(string)
      string.to_s.html_safe
    end

    def render_nav(options, exclude = nil)
      exclude = "Home" if exclude == "Social"
      exclude = "Tags" if exclude == "Tag"
      exclude = "Selected Posts" if exclude == "Selected"
      options = options.dup
      options.delete(exclude)
      options.collect do |name, url|
        [
          "<li class='nav-element' id='#{name.gsub(" ", "-")}'>",
          link_to(name, url),
          "</li>"
        ].join
      end.join("\n").html_safe
    end

    def previous_link(post)
      label = ["&#8592;", title_for(post)].join(" ")
      html_safe_string link_to(label, post_url(post))
    end

    def next_link(post)
      label = [title_for(post), "&#8594;"].join(" ")
      html_safe_string link_to(label, post_url(post))
    end

    def published_date(time)
      return time if time.is_a?(String)

      time.strftime("Written on %A, %B %d, %Y")
    end

    def header(page)
      title = title_for(page)
      subtitle = ""
      unless page["subtitle"].nil? || page["subtitle"] == ""
        subtitle = "<span id='colon'>:</span> <span id='subtitle'>#{page['subtitle']}</span>"
      end

      url = page["url"].to_s.gsub(".haml", ".html")
      html_safe_string "<a href='#{url}'>#{title}</a>#{subtitle}"
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
        document.write('<script charset="utf-8" type="text/javascript" src="https://disqus.com/forums/socialmemorycomplex/get_num_replies.js' + query + '"></' + 'script>');
      })();
      //]]>
      </script>}
    end

    def get_description(page)
      if page.respond_to?(:description)
        page.description
      elsif page.is_a?(Hash) && page["description"]
        page["description"]
      else
        "A political economy of the soul"
      end
    end

    def abridge(html, permalink, para_count)
      paragraph_count = (para_count || 3).to_i
      text = html.gsub(/<h3>.*<\/h3>/, "")
      return text if ((text.size < 2000) || !text.include?("<p>")) && para_count.nil?

      paragraphs = text.split("</p>")[0..(paragraph_count - 1)]
      unless paragraphs.size < paragraph_count
        paragraphs << "<p><a href=\"#{permalink}\">Read more...</a></p>"
      end

      paragraphs.join.html_safe
    end

    def pagination_links(pages)
      links = [
        if (num = pages["previous_page"])
          link_to("&larr; Newer", num == 1 ? "/" : "/page#{num}")
        end,
        unless pages["page"] < 2
          link_to("Home", "/")
        end,
        if (num = pages["next_page"])
          link_to("Older &rarr;", num == 1 ? "/" : "/page#{num}")
        end
      ].compact.collect { |markup| "<li>#{markup}</li>" }.join(" ")
      html_safe_string "<ul>#{links}</ul>"
    end

    def offsite_href(post)
      wp_url =
        if post.is_a?(Hash)
          post["wordpress_url"]
        elsif post.respond_to?(:data)
          post.data["wordpress_url"]
        else
          post["wordpress_url"]
        end

      return wp_url unless wp_url.to_s =~ %r{^http://blog\.6thdensity\.net}

      nil
    end

    def href_for(post)
      offsite_href(post) || post_url(post)
    rescue StandardError
      "/"
    end

    def xml_escape(input)
      "<![CDATA[#{input}]]>"
    end

    def offsite_link(post)
      return nil unless (href = offsite_href(post))

      html_safe_string "<a class=\"outside-link\" href=\"#{href}\">Read this article</a>"
    end

    def link_to(text, href)
      html_safe_string "<a href='#{href}'>#{text}</a>"
    end

    def title_for(obj)
      title =
        case obj
        when Hash
          if obj["tag"]
            "Tag Archive: #{obj['tag']}"
          else
            obj["title"]
          end
        when Jekyll::Document
          obj.data["title"]
        else
          if (tag = obj.fetch("tag", false))
            "Tag Archive: #{tag}"
          else
            obj["title"]
          end
        end

      if title.to_s =~ /\d{18}/
        date =
          if obj.is_a?(Hash)
            obj["date"]
          elsif obj.respond_to?(:date)
            obj.date
          end
        date.strftime("%A, %B %d, %Y")
      else
        title
      end
    end

    def title_or_excerpt(post)
      title = post_value(post, "title")
      if title.to_s =~ /\d{18}/
        text = post_content(post).gsub(/<\/?[^>]*>/, "").gsub("\n", "")
        if text.size > ARCHIVES_EXCERPT_CHAR_LIMIT
          text[0, ARCHIVES_EXCERPT_CHAR_LIMIT] + "..."
        elsif blank?(text)
          title_for(post)
        else
          text[0, ARCHIVES_EXCERPT_CHAR_LIMIT]
        end
      else
        title
      end
    end

    def blank?(string)
      string.gsub(/\s*/, "").empty?
    end

    def atom_entry_for(post)
      %Q~<entry>
  <title>#{post_value(post, 'title')}</title>
  <link href="http://socialmemorycomplex.net#{post_url(post)}" />
  <updated>#{post_date(post).xmlschema}</updated>
  <id>http://socialmemorycomplex.net#{post_url(post)}</id>
  <author><name>Jeremy Weiland</name></author>
  <content type="html">#{xml_escape post_content(post)}</content>
</entry>~
    end

    def atom_entries_for(collection)
      posts =
        if collection.is_a?(String)
          data = page
          eval(collection)
        else
          collection
        end

      Array(posts).map { |post| atom_entry_for(post) }.join
    end

    def render_tags(tags)
      return "".html_safe if tags.nil?

      tags = tags.split(" ") unless tags.is_a?(Array)
      tags.collect { |tag| link_to tag, tag_url(tag) }.join(", ").html_safe
    end

    def tag_cloud(site)
      tag_data = site["tag_data"] || site.data["tag_data"] || {}
      tag_data.map do |tag, set|
        tag_link(tag, tag_url(tag), class: "set-#{set}")
      end.join(" ").html_safe
    end

    def tag_link(tag, url = tag_url(tag), html_opts = nil)
      unless html_opts.nil?
        html_opts = " " + html_opts.map { |key, value| %Q(#{key}="#{value}") }.join(" ")
      end
      html_safe_string %Q(<a href="#{url}"#{html_opts}>#{tag}</a>)
    end

    def tag_url(tag)
      "/tags/#{tag_slug(tag)}/"
    end

    def tag_feed_url(tag)
      "/tags/#{tag_slug(tag)}/feed.xml"
    end

    def tag_slug(tag)
      Jekyll::Tagging.tag_slug(tag)
    end

    def tags(obj)
      obj_tags =
        if obj.is_a?(Hash)
          obj["tags"]
        else
          obj["tags"] || obj.data["tags"]
        end
      obj_tags = obj_tags[0].is_a?(Array) ? obj_tags.map { |tag| tag[0] } : obj_tags
      obj_tags.map { |tag| tag_link(tag, tag_url(tag)) if tag.is_a?(String) }.compact.join(", ")
    end

    private

    def post_url(post)
      if post.respond_to?(:url)
        post.url
      else
        post["url"]
      end
    end

    def post_value(post, key)
      if post.respond_to?(:data)
        post.data[key]
      else
        post[key]
      end
    end

    def post_content(post)
      if post.respond_to?(:content)
        post.content
      else
        post["content"]
      end
    end

    def post_date(post)
      if post.respond_to?(:date)
        post.date
      else
        post["date"]
      end
    end
  end

  class HamlPageConverter < Converter
    safe true
    priority :low

    def matches(ext)
      ext == ".haml"
    end

    def output_ext(_ext)
      ".html"
    end

    def convert(content)
      content
    end
  end

  module HamlRendererPatch
    def render_document
      if haml_page?
        render_haml_page
      else
        super
      end
    end

    def render_layout(output, layout, info)
      if layout.ext == ".haml"
        render_haml_layout(output, layout)
      else
        super
      end
    end

    private

    def haml_page?
      document.is_a?(Jekyll::Page) && document.ext == ".haml"
    end

    def render_haml_page
      output = render_haml(document.content)
      document.content = output
      output = place_in_layouts(output, payload, layout_info) if document.place_in_layout?
      output
    end

    def render_haml_layout(output, layout)
      payload["content"] = output
      payload["layout"] = Jekyll::Utils.deep_merge_hashes(layout.data, payload["layout"] || {})
      render_haml(layout.content)
    end

    def render_haml(template)
      haml_scope = Object.new.extend(HamlHelpers)
      binding_obj = haml_scope.instance_eval { binding }

      haml_locals.each do |key, value|
        binding_obj.local_variable_set(key.to_sym, value)
        haml_scope.define_singleton_method(key) { value }
      end

      compiled = Haml::Engine.new(format: :xhtml).call(template)
      eval(compiled, binding_obj)
    end

    def haml_locals
      {
        "site" => payload["site"],
        "page" => payload["page"],
        "content" => payload["content"],
        "paginator" => payload["paginator"],
        "layout" => payload["layout"]
      }
    end

    def layout_info
      {
        registers: { site: site, page: payload["page"] },
        strict_filters: liquid_options["strict_filters"],
        strict_variables: liquid_options["strict_variables"]
      }
    end
  end
end

Jekyll::Renderer.prepend(Jekyll::HamlRendererPatch)
