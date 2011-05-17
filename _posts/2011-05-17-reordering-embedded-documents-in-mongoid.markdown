---
title: Reordering embedded documents in mongoid
tags: mongodb, mongoid, ruby, rails
---

One of the great things about embedded documents in MongoDB is that you can design you "schema" according to how you're going to use the data. Ordered lists of objects is a great use for embedded documents, as you can just shove objects in an array and read them out in order. This allows one to dispense with the unpleasantness of "acts_as_list"-style approaches where you have to juggle a "position" field and do an explicit sort.

But what if you want to reorder the embedded documents? Should be simple to sort an array. Our ODM - [Mongoid](http://mongoid.org) would _never_ represent the embedded collection as an array and not let us work with it as an array, right?

{% highlight ruby %}
class Container
	include Mongoid::Document
	
	embeds_many :items
end

class Item
	include Mongoid::Document
	
	embedded_in :container
	
	field :title, :as => String
end

c = Container.create
c.items.create :title => "first"
c.items.create :title => "second"

>> c.items
=> [#<Item _id: 4dd2d971322bcdab7c000003, title: "first", _id: BSON::ObjectId('4dd2d971322bcdab7c000003'), _type: nil>, #<Item _id: 4dd2d981322bcdab7c000004, title: "second", _id: BSON::ObjectId('4dd2d981322bcdab7c000004'), _type: nil>]
>> c.items.reverse!
=> [#<Item _id: 4dd2d981322bcdab7c000004, title: "second", _id: BSON::ObjectId('4dd2d981322bcdab7c000004'), _type: nil>, #<Item _id: 4dd2d971322bcdab7c000003, title: "first", _id: BSON::ObjectId('4dd2d971322bcdab7c000003'), _type: nil>]
>> c.save
=> true
>> c.reload.items
=> [#<Item _id: 4dd2d971322bcdab7c000003, title: "first", _id: BSON::ObjectId('4dd2d971322bcdab7c000003'), _type: nil>, #<Item _id: 4dd2d981322bcdab7c000004, title: "second", _id: BSON::ObjectId('4dd2d981322bcdab7c000004'), _type: nil>]
{% endhighlight %}

OK, so not that easy, but maybe this means we just need to set the new array explicitly.

{% highlight ruby %}
>> c.items = c.items.reverse
=> []
{% endhighlight %}

Yikes. So what do we do? Well, here's how I worked around it:

{% highlight ruby %}
reordered_items = c.items.reverse
c.items.clear
reordered_items.each { |i| c.items.create i.attributes }
{% endhighlight %}

This works for me, but it's not very elegant. Any problems with this approach? Feel free to let me know.