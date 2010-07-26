---
title: Announcing greedy
tags: ruby
---

This weekend I released my first ruby gem: [greedy](http://github.com/jeremy6d/greedy). Greedy provides a layer on top of the Google Reader API to facilitate the consumption of feed items syndicated by Google Reader for a given Google account. Using it is pretty simple:

`require 'greedy'
my_reading_list = Greedy::Stream.new 'username', 'password'
stories = my_reading_list.entries # each story as a Greedy::Entry
my_reading_.continue! # get earlier stories in the stream of news
my_reading_list.update! # get later stories in the stream of news

story = stories.first # Greedy::Entry
story.title # the title
story.body # the normalized body text
story.truncated_body # the body text truncated to first three paragraphs, can be customized`

Greedy was extracted from another project that went up today, although not for the first time: [leftlibertarian.org](http://leftlibertarian.org). Now that the Google Reader API stuff has been successfully extracted, the next step is to make the code that runs leftlibertarian.org into something anybody can use to publish their Google Reader stream as a website. Hopefully, that won't be too long in coming...