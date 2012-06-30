---
title: Add Sound to Autotest on OS X
tags: ruby, tdd, bdd, testing
---

To me, development is all about communication. With clients and other developers, sure, but mostly with the computer itself. I'm trying to describe to the computer how to accomplish a task it does not have any capacity to understand or appreciate. On the other hand, the context of a given problem can be so natural to me that I have a hard time articulating it. Using [autotest](http://github.com/grosser/autotest), I can engage in a sort of conversation with the computer, where it tells me in real time as I program whether it understands what I'm telling it or not.

A Growl notification informing me of test results is great, and I can even tell Growl to play a sound when the notification is ready. But that sound tells me to look for the notification, not whether the tests pass or fail. To make this conversation more fluid, it would be nice if I had not just visual but also audio feedback which told me immediately what the test results were, instead of having to constantly context switch to the test results.

There have been a [few](http://www.fozworks.com/2007/7/28/autotest-sound-effects) [attempts](http://www.metaskills.net/2008/4/6/autotest-playlist-for-red-green-feedback) to do this already, but they all seem so complex. I found a simple command line sound file player called [afplay](http://developer.apple.com/mac/library/documentation/Darwin/Reference/ManPages/man1/afplay.1.html) that makes all this trivial. In your ~/.autotest file, add the following:

    def play(filename, volume = ".15")
      system "afplay -v #{volume} /Users/jeremyweiland/.autotest_sounds/#{filename}.wav"
    end
     
    Autotest.add_hook :ran_command do |at|
      play(at.results.detect { |line| line.include?("0 failures, 0 errors") } ? "passed" : "failed")
    end

    Autotest.add_hook :run_command do |at|
      play("running")
    end

This will play some select sounds when tests start running, pass, and fail. Just drop audio files in ~/.autotest_sounds and name them appropriately. Here are [my sounds](/media/dot-autotest_sounds.zip) to get you started. The "play" method can be modified to use the "say" command or play any sound file you want.

I find that being able to use my ears to help have this difficult conversation helps me stay in the flow of the conversation more, where I do better and faster work.