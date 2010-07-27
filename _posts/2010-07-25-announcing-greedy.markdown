---
title: Announcing greedy
tags: ruby
---

This weekend I released my first ruby gem: [greedy](http://github.com/jeremy6d/greedy). Greedy provides a layer on top of the Google Reader API to facilitate the consumption of feed items syndicated by Google Reader for a given Google account. John Nunemaker's GoogleReader gem was the inspiration, but it used an authentication method that has been discontinued by Google. I switched to using the gdata gem.

Right now I can't figure out how to post information to the Google Reader API. Anybody who could help me figure out why my code isn't working is welcome to fork and submit pull requests - I know I'm missing something simple. When that feature works, you'll be able to use greedy to change the state of items to "shared", "read", "unread", etc. However, the code that merely consumes feed items is ready for action.

Greedy was extracted from another project that went up today, although not for the first time: [leftlibertarian.org](http://leftlibertarian.org). Now that the Google Reader API stuff has been successfully extracted, the next step is to make the code that runs leftlibertarian.org into something anybody can use to publish their Google Reader stream as a website. Hopefully, that won't be too long in coming...

