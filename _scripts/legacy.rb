require 'pp'

POSTS_PATH = "/Users/jeremyweiland/Development/blog/_posts"

Dir.new(POSTS_PATH).entries.select do |filename|
  ["html", "haml", "markdown"].include? filename.split(".").last
end.collect do |filename|
  text = File.open(File.join(POSTS_PATH, filename), "r").read
  next unless matchinfo = /wordpress_url:\s(.+)\n/.match(text)
  wp_url = matchinfo.captures.first  
  [wp_url, "http://socialmemorycomplex.com/#{filename}"] if wp_url.include?("blog.6thdensity.net")
end.compact.each do |line|
  [[".", "\\."], ["?", "\\?"], ["/", "\\/"]].each do |pair|
    line.first.gsub! pair.first, pair.last
  end
  puts "rewrite ^#{line.first}$ #{line.last} permanent;"
end