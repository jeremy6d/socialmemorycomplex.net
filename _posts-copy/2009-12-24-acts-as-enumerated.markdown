---
layout: post
title: acts_as_enumerated Blowing Up Your Testing Spot?
published: true
tags: ruby, rails, testing, development
---
If acts_as_enumerated classes are borking when you run your tests, here's a nasty workaround I did that just might work for you:
{% highlight ruby %}
          class MembershipStatus < ActiveRecord::Base
  if RAILS_ENV == 'test'
    def self.[](label)
      case label
      when :pending
        MembershipStatus.new(:id => 1)
      when :accepted
        MembershipStatus.new(:id => 2)
      when :denied
        MembershipStatus.new(:id => 3)
      when :invited
        MembershipStatus.new(:id => 4)
      end
    end
  else
    acts_as_enumerated
  end
end
{% endhighlight %}
