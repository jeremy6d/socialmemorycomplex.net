--- 
wordpress_id: 1333
title: An RJS Redirect Matcher for rspec
wordpress_url: http://blog.6thdensity.net/?p=1333
layout: post
---
<p>You know what's stupid?  Clumsily checking for a javascript redirect in your RJS with this kind of shit:</p>
<pre lang="ruby">it "should redirect to the collaborative quote screen" do
  xhr :post, 'attach', :attachment_id => '4023'
  response.body.should =~ /window\.location\.href = \"/collabquote\";"
end</pre>
<p>Not only is this ugly, but it ties your test to a particular route, rather than allowing you to use your named route.  So I whipped up a custom RJS redirect matcher in about 10 minutes following the guidelines in <a href="http://www.sameshirteveryday.com/2007/09/15/rspec-custom-expectation-matcher-example/">this post</a>, and I was surprised how easy it was.<!--more-->  It should be pretty self explanatory.</p>
<pre lang="ruby">module RedirectViaRjsToMatcher  
  class RedirectViaRjsTo  
    def initialize(expected)  
      @expected = expected  
    end  

    def matches?(target)  
      @target = target
      @url = target.body.split('"')[1]
      @target.body == "window.location.href = \"#{@expected}\";"
    end  

    def failure_message  
      "expected redirect via rjs to #{@expected}, redirected instead to #{@url}"
    end  

    def negative_failure_message  
      "unexpected redirect via rjs to #{@expected}"  
    end
  end
  
  # Actual matcher that is exposed 
  def redirect_via_rjs_to(expected)  
    RedirectViaRjsTo.new(expected)  
  end
end</pre>
<p>All you need to do is save this file in /spec/custom/redirect_via_rjs_to.rb and include it in /spec/spec_helper.rb like so:</p>
<pre lang="ruby">require 'spec/be_the_same_as'

Spec::Runner.configure do |config|  
  config.include(RedirectViaRjsToMatcher)  
end</pre>
<p>Voilla!  It really is that easy, and turns that first spec into something a bit more readable and reusable:</p>
<pre lang="ruby">it "should redirect to the collaborative quote screen" do
  xhr :post, 'attach', :attachment_id => '4023'
  response.should redirect_via_rjs_to quote_path(@quote)
end</pre>
<p><strong>UPDATE:</strong> <a href="http://someguysblog.com/">Jim</a> clued me into <a href="http://apidock.com/rspec/Spec/Matchers/simple_matcher">simple_matcher</a>, which appears to be yet another very easy way to create custom matchers.</p>
