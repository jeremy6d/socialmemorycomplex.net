module Jekyll
  class Post
    def initialize(site, source, dir, name)
      @site = site
      @base = File.join(source, dir, '_posts')
      @name = name

      self.categories = dir.split('/').reject { |x| x.empty? }
      self.process(name)
      self.read_yaml(@base, name)
      
      # Set a default layout for posts
      unless self.data.has_key?('layout')
        self.data['layout'] = 'post'
      end

      #If we've added a date and time to the yaml, use that instead of the filename date
      #Means we'll sort correctly.
      if self.data.has_key?('date')
        # ensure Time via to_s and reparse
        self.date = Time.parse(self.data["date"].to_s)
      end

      if self.data.has_key?('published') && self.data['published'] == false
        self.published = false
      else
        self.published = true
      end

      self.tags = self.data.pluralized_array("tag", "tags")

      if self.categories.empty?
        self.categories = self.data.pluralized_array('category', 'categories')
      end
    end
  end
end

