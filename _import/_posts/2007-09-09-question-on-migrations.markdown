--- 
wordpress_id: 790
title: Question on migrations
wordpress_url: http://blog.6thdensity.net/?p=790
layout: post
---
<p>OK.  So you have been using migrations to iteratively modify your database and populate it with information as you flesh out your application.  Awesome. Now, what happens when you change the model definitions and try to rollback and then roll forward?</p><p>This is the problem I'm encountering.  For example, I've made changes to my models through the lifecycle of the app, mostly in adding new fields and deleting others. The model code validates the presence of the most recent set of fields.  But in those earlier migrations, I populated the database with model objects that don't supply that field, or supply different fields, based on the model definition at that time.  So if I ever roll back to those earlier migrations, they are apt to fail because model objects are being created based on an outdated model definition.</p><p>What is the proper Rails method of dealing with the mismatch between the current model code and legacy migrations that use out-of-date model definitions?  I haven't been able to find any guidance on this matter, which leads me to conclude that I'm asking the wrong question here.</p>
