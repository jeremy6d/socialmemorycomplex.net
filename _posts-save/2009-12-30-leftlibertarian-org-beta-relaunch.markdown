---
layout: post
title: leftlibertarian.org Beta Relaunch
tags: ruby, left-libertarian
category: leftlibertarian
---

[leftlibertarian.org](http://leftlibertarian.org) is back! I've moved the site off WordPress, which was giving me too many problems. The site should be simple enough - there's no commenting, and the core functionality has nothing to do with _creating_ content, only publishing it. So I started thinking about why I was going out and gathering / parsing feeds when Google Reader does it perfectly well, and has an API I can access.

The new site has a Google Reader account associated with it (leftlibertarian.org). Instead of going out to a list of feeds, downloading them, databasing posts, and generating web pages on requests, I just grab a JSON encoded version of my reading list as if my site were a Google Reader user and generate pages off of that! Super fast, super lightweight, super easy (once I figured out how I wanted to go about it).

The cool thing about this is that the API makes available just about all of the Google Reader features, including starring, comments, sharing, etc. The Google Reader web application is really just a front end for a rather powerful backend. Over the long run, I'd like to leverage these features to make the site more socially driven and dynamic but without needing a database or anything but a basic web server, cron, and ruby.

The site is very much beta right now. I'm using a HTML parsing library to truncate posts, so if you see anomalies there or have any other comments, let me know. admin atsign left libertarian period org