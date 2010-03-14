--- 
wordpress_id: 492
title: "Learn From My Pain: Deploying Rails on DreamHost"
wordpress_url: http://blog.6thdensity.net/?p=492
layout: post
---
Since it seems like <a href="http://dreamhost.com">DreamHost</a> is a pretty popular hosting solution for people who are getting into <a href="http://www.rubyonrails.org">Ruby on Rails</a> programming, I thought I'd try to give some advice on how to avoid the headaches.  It took me 4 or 5 days to successfully deploy the most basic of web apps just because following the advice of kind strangers simply doesn't always work.  So, I thought I'd provide some more kind stranger advice.  This may be a little roundabout but it's a very predictable way to deploy, at least for me.  Your milage may vary.

Let's walk through the easy way to set up a rails app at <em>example.com</em> - note that whereever I use <em>example.com</em> you should substitute your domain name.  Double check that you have a directory in your file area that matches the domain name you're using (<code>/home/username/example.com</code>).  Also, if you're a little rusty on Unix like I am, remember that whenever I use <code>~/</code> that means <code>/home/username/</code> (where <em>username</em> is your DH username, of course).
<ol>
	<li>Make sure you're starting completely from scratch.  We should have a vanilla domain setup in the <a href="http://panel.dreamhost.com">DH control panel</a> under "Domains > Domain Manager", and no files whatsoever in <code>~/example.com/</code></li>
	<li>Login to SSH and <code>cd ~/</code></li>
	<li>Type <code>rails example.com</code>  This will create a rails app at example.com which is setup up to run on the server, so it will know where ruby is installed, for instance, and what version of Rails is installed without you having to research it.  Currently, DH runs Rails 1.1.2.</li>
	<li>Return to the Domain Manager and make sure FastCGI support is checked.  Also, change the web directory path so that the entire path reads: <code>/home/username/example.com/public/</code></li>
	<li>Wait a few minutes, then navigate in your browser to example.com.  You should see the Rails welcome page.</li>
	<li>Return to SSH, and copy the <code>app</code> directory of your application into <code>~/example.com/app/</code></li>
	<li>Set up your databases in MySQL if you haven't already.  Go to the <a href="http://panel.dreamhost.com">DH control panel</a> and navigate on the sidebar to "Goodies > Manage MySQL".  Then create your database and also create a new hostname ("mysql.example.com").  Note the username (create a new one) and password you use.  Go ahead and create a development, test, and production database so that your migration will work (you are using <a href="http://wiki.rubyonrails.org/rails/pages/UnderstandingMigrations">migrations</a>, right?).</li>
	<li>Amend <code>~/example.com/config/database.yml</code> to reflect your database setup.  Make sure you change the host to mysql.example.com.If the database gives you problems and you're sure this file correctly reflects your database's account setup, you may find taking out the adapter line and putting in port: 3306 might help.  It didn't for me, so try it without these changes first.</li>
	<li>Amend <code>~/example.com/config/environment.rb</code> to ensure that there's a line like this at the top:
<pre style="border: 2px solid #d0d0d0; padding: 10px; background-color: #f6f6f6; color: #000066">ENV['RAILS_ENV'] = 'production'</pre>
</li>
	<li>Check to make sure you have a route for the webroot in <code>~/example.com/config/routes.rb</code>  If not, uncomment this line:
<pre style="border: 2px solid #d0d0d0; padding: 10px; background-color: #f6f6f6; color: #000066"># map.connect '', :controller => "welcome"</pre>
and fill in the controller which you want to handle any visits to http://example.com</li>
	<li>Modify all instances of <strong>dispatch.cgi</strong> in the <code>~/example.com/public/.htaccess</code> file to <strong>dispatch.fcgi</strong>. In the current version of rails, there is only one line to change, on line 32:From:
<pre style="border: 2px solid #d0d0d0; padding: 10px; background-color: #f6f6f6; color: #000066">RewriteRule ^(.*)$ dispatch<strong>.cgi</strong> [QSA,L]</pre>
to:
<pre style="border: 2px solid #d0d0d0; padding: 10px; background-color: #f6f6f6; color: #000066">RewriteRule ^(.*)$ dispatch<strong>.fcgi</strong> [QSA,L]</pre>
</li>
	<li>Dreamhost regularly kills off sleeping processes with their watchdog. This will kill your dispatch.fcgi processes, leading to Error 500s from time to time. You'll need to make dispatch.fcgi ignore all TERM requests by changing how it responds to them.After <code>require 'fcgi_handler'</code>, change the rest of <code>~/example.com/public/dispatch.fcgi</code> to read:
<pre style="border: 2px solid #d0d0d0; padding: 10px; background-color: #f6f6f6; color: #000066">class RailsFCGIHandler
private
def frao_handler(signal)
dispatcher_log :info, "asked to terminate immediately"
dispatcher_log :info, "frao handler working its magic!"
restart_handler(signal)
end
alias_method :exit_now_handler, :frao_handler
end

RailsFCGIHandler.process!</pre>
And save the file.</li>
	<li>At SSH,</li>
<ol>
	<li><code>cd ~/example.com/</code></li>
	<li><code>chmod -R u+rwX,go-w public log</code></li>
	<li>Now run your migration, which will bring your database schema up to date: <code>rake migrate</code></li>
	<li><code>rm ~/example.com/public/index.html</code></li>
</ol>
	<li>You should be running!</li>
</ol>
If at first you get errors, give it a while.  I had a problem where I followed these steps and couldn't get the webroot to route correctly (http://example.com was not being routed to my controller even though I specified it in routes.rb).  I went to bed after messing with it for hours, woke up and tried it, and it was fine.  So make sure that you give things time to fix themselves.  Also, check the <a href="http://wiki.dreamhost.com/index.php/Ruby_on_Rails#QuickStart_Guide">DreamHost Rails Deployment Wiki page</a> for more tips and help.

Happy deploying!
