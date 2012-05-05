--- 
wordpress_id: 511
title: Xubuntu installation is a pain
wordpress_url: http://blog.6thdensity.net/?p=511
layout: post
---
So my wife got a new computer courtesy of <a href="http://blog.mattwalters.net">Matt</a>, and I took her old one to have my dirty way with it.  I've been wanting to try out Linux for a while, so I grabbed a copy of <a href="http://ubuntu.com">Ubuntu</a> since it's supposed to be so super easy to install.  However, the computer is so old that it was sagging running off the Live CD (keep in mind this is a P2 400 Mhz with maybe 128 megs of RAM and a 4X CD-ROM drive).  Waiting 15 minutes - literally - for a response to a mouse click just wasn't cutting it.

So I grabbed a copy of <a href="http://xubuntu.com">Xubuntu</a> and went to install that.  It's supposed to run better on older computers.  Apparently there are very few display drivers on the Live CD and so I was stuck in 640x400 or something like that.  Which would be fine if the installation windows shrunk to conform, but they don't.  So most of the controls I need to click on to go through the installation are completely off screen.  Additionally, there wasn't a consistent tabbing scheme on one of the screens (the time zone selection one needs you to Ctrl+tab or Alt+tab or something, not tab through).

But I'm finally installing.  I'll let you know if I run into any more problems, but I had to bitch about that.

UPDATE: Got it installed no problem, but continued to be plagued by low resolution.  Eventually hacked my way into /etc/X11/xorg.conf and had success when I amended my monitor settings to define HorizSync and VertRefresh values (hint: look up your monitor's specs online).  <s>I can't find the discussion that tipped me off there, but I bet if you search hard enough you can find it.</s>  Read more <a href="https://help.ubuntu.com/community/FixVideoResolutionHowto">here</a>.

Now to get my network card working!
