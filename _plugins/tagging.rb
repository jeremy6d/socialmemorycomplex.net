# frozen_string_literal: true

require "active_support/inflector"

module Jekyll
  module Tagging
    module_function

    def tag_slug(name)
      ActiveSupport::Inflector.transliterate(name.to_s)
        .downcase
        .gsub(/[^a-z0-9]+/, "-")
        .gsub(/\A-+|-+\z/, "")
    end

    class Generator < Jekyll::Generator
      safe true
      priority :low

      def generate(site)
        @site = site
        site.data["tag_data"] = calculate_tag_data(site)
        generate_tag_pages(site)
      end

      private

      def generate_tag_pages(site)
        active_tags(site).each do |tag, posts|
          sorted = posts.sort_by(&:date).reverse
          create_tag_page(site, tag, sorted, :page) if site.config["tag_page_layout"]
          create_tag_page(site, tag, sorted, :feed) if site.config["tag_feed_layout"]
        end
      end

      def create_tag_page(site, tag, posts, type)
        layout = site.config["tag_#{type}_layout"]
        dir_base = site.config["tag_#{type}_dir"] || "tags"
        slug = Tagging.tag_slug(tag)
        dir = File.join(dir_base, slug)
        name = type == :feed ? "feed.xml" : "index.html"

        data = {
          "layout" => layout,
          "tag" => tag,
          "posts" => posts,
          "title" => tag,
          "subtitle" => "Social Memory Complex"
        }.merge(site.config["tag_#{type}_data"] || {})

        page = Jekyll::PageWithoutAFile.new(site, site.source, dir, name)
        page.data = data
        site.pages << page
      end

      def active_tags(site)
        tags = site.tags
        ignored = site.config["ignored_tags"]
        return tags unless ignored

        tags.reject { |tag, _| ignored.include?(tag) }
      end

      def calculate_tag_data(site)
        tag_counts = active_tags(site).values.map(&:size)
        max = tag_counts.max.to_f
        max = 1 if max.zero?

        active_tags(site).each_with_object({}) do |(tag, posts), hash|
          hash[tag] = [((posts.size / max) * 5).ceil, 1].max
        end
      end
    end
  end
end
