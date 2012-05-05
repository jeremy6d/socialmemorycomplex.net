module Jekyll
  class Pager
    def self.pagination_enabled?(config, file)
      (file == 'index.haml') && !config['paginate'].nil?
    end
  end
  
  class Page
    def destination(dest)
      # The url needs to be unescaped in order to preserve the correct
      # filename.
      path = File.join(dest, @dir, CGI.unescape(self.url))
      path = File.join(path, "index.html") if self.url =~ /\/$/
      path.gsub(/\.haml$/, ".html")
    end
  end
  
  class Post
    def destination(dest)
      # The url needs to be unescaped in order to preserve the correct filename
      path = File.join(dest, CGI.unescape(self.url))
      path = File.join(path, "index.html") if template[/\.html$/].nil?
      path.gsub(/\.haml$/, ".html")
    end
  end
end
    