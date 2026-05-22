Jekyll::Hooks.register :posts, :post_init do |post|
  post.data["layout"] = "post" unless post.data.key?("layout")
end

module Jekyll
  class Page
    def title
      if data["title"] =~ /\d{18}/
        data["date"].strftime("%A, %B %d, %Y")
      else
        data["title"]
      end
    end
  end

  class Document
    def title
      if data["title"] =~ /\d{18}/
        date.strftime("%A, %B %d, %Y")
      else
        data["title"]
      end
    end
  end
end
