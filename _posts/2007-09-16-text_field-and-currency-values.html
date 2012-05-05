--- 
wordpress_id: 793
title: text_field and currency values
wordpress_url: http://blog.6thdensity.net/?p=793
layout: post
---
<p>I've asked around about this issue and nobody has been able to give me a straightforward solution.  It is for that reason that I'm not afraid to share my hack.  If there's a better way to do this in Rails, let me know.</p><p>The problem: you're using some sort Numeric field for storing monetary values.  But you can't guarantee how those values will be formatted in the view.  It looks best when a field containing a dollar amount is formatted like "2.00" instead of "2" or "2.0" or, god forbid, "2.000".  But you can't do formatting of the Numeric type (you should be using BigDecimal, btw) and there's no way to get between the view's conversion of the number to a string.  At least, not without a custom getter / setter in the model.</p><p>My solution keeps formatting code in the view, where it belongs.  I essentially create a helper method for that view called "monetary_field" that does the string conversion when the text_field tag is rendered.  In my template:<blockquote><pre lang="ruby"><%= monetary_field 'contribution', 'amount', @contribution.amount %></pre></blockquote>And my helper method:<blockquote><pre lang="ruby">def monetary_field(objname, method, value)
  text_field "#{objname}", "#{method}", :value => ("%0.2f" % value), :size => 6
end</pre></blockquote>It works very well for my purposes, though you could make it prettier and more universally applicable.  Unfortunately, my deadline is tomorrow, so none of that.  But hopefully if anybody else has this problem they'll find this super simple way to get between the model and the view easily.</p>
