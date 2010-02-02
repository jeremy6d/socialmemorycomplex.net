---
layout: post
title: Need git aliases?
tags: git
---
I've used git on many other people's computers and they never have the shortcuts that make git nimble for me to use. Until just now, I had know idea how those aliases were set. From a cursory reading of [the docs](http://www.kernel.org/pub/software/scm/git/docs/git-config.html), I gathered that you can edit your aliases directly with `git config --global -e`. For example:

{% highlight sh %}        
[merge]
	tool = opendiff
[core]
	excludesfile = /Users/jeremyweiland/.gitignore
	editor = mate -w
[alias]
	st = status
	ci = commit
	co = checkout
	br = branch
	lg = log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr)%Creset' --abbrev-commit --date=relative
[color]
	pager = true
	ui = auto
{% endhighlight %}