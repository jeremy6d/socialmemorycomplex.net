---
title: Reordering embedded documents in Mongoid
tags: mongodb mongoid ruby rails
---

One of the great things about embedded documents in [MongoDB](http://mongodb.org) is that you can design your "schema" according to how you're going to use the data. Ordered lists of objects is a great use for embedded documents, as you can just shove objects in an array and read them out in order. This allows one to dispense with the unpleasantness of "acts_as_list"-style approaches where you have to juggle a "position" field and do an explicit sort.

But what if you want to reorder the embedded documents? Should be simple to sort an array. Our <abbr title="Object Document Mapper">ODM</abbr> - [Mongoid](http://mongoid.org) in this case - would _never_ represent the embedded collection as an array and not let us work with it as an array, right?

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

OK, so not that easy, but maybe this means we just need to set the new array explicitly.

    >> c.items = c.items.reverse
    => []

Yikes. So we can treat it as an array as much as we want - as long as we don't need to persist it. Keep in mind this is a MongoDB trait, not a failing of the ODM per se (though one would expect the ODM to help us out here!).

So what do we do? Well, I worked around it by explicitly rebuilding the array of embedded documents:

    >> reordered_items = c.items.reverse
    => [#<Item _id: 4dd2e0b7322bcdae0d000002, title: "second", _id: BSON::ObjectId('4dd2e0b7322bcdae0d000002'), _type: nil>, #<Item _id: 4dd2e0b6322bcdae0d000001, title: "first", _id: BSON::ObjectId('4dd2e0b6322bcdae0d000001'), _type: nil>]
    >> c.items.clear
    => []
    >> reordered_items.each { |i| c.items.create i.attributes }
    => [#<Item _id: 4dd2e0b7322bcdae0d000002, title: "second", _id: BSON::ObjectId('4dd2e0b7322bcdae0d000002'), _type: nil>, #<Item _id: 4dd2e0b6322bcdae0d000001, title: "first", _id: BSON::ObjectId('4dd2e0b6322bcdae0d000001'), _type: nil>]
    >> c.reload.items
    => [#<Item _id: 4dd2e0b7322bcdae0d000002, title: "second", _id: BSON::ObjectId('4dd2e0b7322bcdae0d000002'), _type: nil>, #<Item _id: 4dd2e0b6322bcdae0d000001, title: "first", _id: BSON::ObjectId('4dd2e0b6322bcdae0d000001'), _type: nil>]

This works for me, but it's not very elegant. Any problems with this approach? Feel free to let me know.