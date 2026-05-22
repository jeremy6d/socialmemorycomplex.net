require "jekyll-paginate/pager"

module Jekyll
  module Paginate
    class Pager
      class << self
        alias_method :original_pagination_candidate?, :pagination_candidate?

        def pagination_candidate?(config, page)
          return true if page.name == "index.haml" && page.dir == "/"

          original_pagination_candidate?(config, page)
        end
      end
    end
  end
end
