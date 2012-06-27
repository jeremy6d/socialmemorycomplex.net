---
title: GridFS with Mongoid and CarrierWave on Rails 3
tags: rails, ruby, mongodb, mongoid, carrierwave, rails3
---

Over the last week I've started a project with [Rails 3](http://guides.rails.info/3_0_release_notes.html) and I'm impressed. The increased configurability of the framework has not diminished its ease of use nor its core concepts in the slightest. You'll have to get used to a few new conventions, especially regarding routing, but there's lots of help out there.

Since this project is something I'm doing in my off time, I decided to experiment with [MongoDB](http://www.mongodb.org/) using the [Mongoid](http://mongoid.org) framework. I had played with MongoMapper before, but always felt like I was using an ActiveRecord clone that didn't take advantage of the full capabilities of a document database and was forcing and ActiveRecord-style approach on me. With Mongoid you get has\_many, has\_one, and belongs\_to relationships that map to MongoDB concepts like embedded documents. Mongoid is fully compatible with the [ActiveModel](http://github.com/rails/rails/tree/master/activemodel) interface for Rails3, and things like associations and nested attributes work out of the box.

I also had been hearing great things about [CarrierWave](http://github.com/jnicklas/carrierwave) from co-workers. It employs the concept of an "uploader" outside of the MVC ecosystem. The uploader handles resizing, storage, and all other details. In your model, you simply "mount" the uploader and you're golden. Of course, for this project the killer feature is the GridFS storage option, which is something I wanted to play with.

[GridFS](http://www.mongodb.org/display/DOCS/GridFS+Specification) is a feature of MongoDB that allows storage of large files inside the database. It chunks the file into pieces and assigns a database index so the file can be associated with other documents. While CarrierWave takes care of getting the file _into_ GridFS, serving the file back out is a bit trickier. CarrierWave gives you all you need to configure the url at which your file will be served, but you have to roll your own mechanism for serving it. But I'll walk you through it.

I'll assume you have the right version of Rails 3 installed - it's changing too frequently to document here. Once you've got that, create your app with `rails appname --skip-activerecord` and navigate up in that piece.

I've discovered through trial and error that your Bundler config for all the gems mentioned here should track their respective master git branches, since a lot of the Rails 3 compatibility issues are still being worked out. I also track Rails edge because, at this point, why wouldn't you? So, get your Gemfile looking like this:

    source :rubygems
    gem 'bson_ext'

    gem 'rails', :git => 'http://github.com/rails/rails.git', :branch => 'master'
    gem 'mongoid', :git => 'git://github.com/durran/mongoid.git'
    gem 'carrierwave', :git => "git://github.com/jnicklas/carrierwave.git"
    gem 'mini_magick', :git => 'git://github.com/probablycorey/mini_magick.git'

I included [MiniMagick](http://github.com/probablycorey/mini_magick), but you can choose your own image processing library - just remember to change lines referencing MiniMagick in future code examples. 

Now let's install your gem bundle. I recommend calling `bundle install vendor` to get all your gems vendored in your Rails app, which makes tracking gems much more straightforward. 

Next step is to run `rails generate mongoid:config` which generates a `config/mongoid.yml` file. You'll need to fill in the details, but I recommend something a bit like this just to get started:

    defaults: &defaults
      host: localhost

    development:
      <<: *defaults
      database: appname_development

    test:
      <<: *defaults
      database: appname_test

The generator will also place `require 'mongoid/railtie'` at the top of your `config/application.rb` file. I recommend setting up your generators with Mongoid by adding this line in the config block:

    config.generators do |g|
      g.orm :mongoid
      g.template_engine :erb # this could be :haml or whatever
      g.test_framework :test_unit, :fixture => false # this could be :rpsec or whatever
    end

Those generator settings will allow the resource generator to give you exactly the models, views, and controllers you want by invoking `rails generate scaffold thing`. Now let's go into `app/models/thing.rb` and add the following:
  
    require 'carrierwave/orm/mongoid'

    class Thing
      include Mongoid::Document
      mount_uploader :image, ImageUploader
    end

This is the equivalent of Paperclip's `has_attached_file` or Attachment_fu's `has_attachment` - except that you don't do all the configuration for upload processing there. Instead you do it in the uploader class, which you can generate by invoking `rails generate uploader image`. This will create an `uploaders/image.rb` file, which is a slight quirk because Rails doesn't know how to find this file when looking up the `ImageUploader` class. We're going to change the name of the file to `uploaders/image_uploader.rb` so it conforms to ruby's conventions for class definition files. 

I'm going to use MiniMagick to process thumbnails, so here's my fully configured uploader file:

    require 'carrierwave/processing/mini_magick'

    class ImageUploader < CarrierWave::Uploader::Base
      include CarrierWave::MiniMagick
      
      version :thumb do
        process :resize_to_fill => [80,80]
      end
    end

There's some CarrierWave settings we should set up globally, such as all the MongoDB and GridFS stuff. An initializer is the best place for that junk, so stick this in a new file called `config/initializers/carrierwave.rb`:

    CarrierWave.configure do |config|
      config.grid_fs_database = Mongoid.database.name
      config.grid_fs_host = Mongoid.config.master.connection.host
      config.storage = :grid_fs
      config.grid_fs_access_url = "/images"
    end

Note the `config.grid_fs_access_url = "/images"` line, which helps CarrierWave figure out what url to serve this under. The actual url it generates will look like `/images/uploads/version_filename.jpg`, which is fine for now - you can configure this to your liking later.

Now we just need to update the form to allowing file uploads. Make your "thing" form partial look like this, noting the file field and mulitpart form lines in particular:

    <%= form_for(@thing, :html => { :multipart => true }) do |f| %>
      <% if @thing.errors.any? %>
        <div id="error_explanation">
          <h2><%= pluralize(@thing.errors.count, "error") %> prohibited this thing from being saved:</h2>

          <ul>
          <% @thing.errors.full_messages.each do |msg| %>
            <li><%= msg %></li>
          <% end %>
          </ul>
        </div>
      <% end %>
      
      <%= f.label :image %>
      <%= f.file_field :image %>

      <div class="actions">
        <%= f.submit %>
      </div>
    <% end %>

And let's amend the show view to display the image. Notice we pass the version into the `url` method to access a particular version.

    <p id="notice"><%= notice %></p>
    <%= image_tag @thing.image.url(:thumb) %>

    <%= link_to 'Edit', edit_thing_path(@thing) %> |
    <%= link_to 'Back', things_path %>

We can start up the server by invoking `rails server`. Navigating to `http://localhost:3000/things/new` should give us a form where we can select an image to upload. The image should get uploaded and the "thing" saved without a hitch, but when it redirects you to view the "thing" there will be a broken image waiting for you. This is because Rails has no freakin' clue how to access the file via GridFS. So we need to tell it how.

In order to serve the image as quickly as possible, we need a way to access GridFS without involving the entire Rails slow-ass stack. Enter Rails Metal, which allows you to process requests directly from Rack. While Rails 2 required you to place metal processing in its own directory under app, Rails 3 bakes Rack support directly into the inheritance hierarchy of ActionController, allowing you to do something like this:

    require 'mongo'

    class GridfsController < ActionController::Metal
      def serve
        gridfs_path = env["PATH_INFO"].gsub("/images/", "")
        begin
          gridfs_file = Mongo::GridFileSystem.new(Mongoid.database).open(gridfs_path, 'r')
          self.response_body = gridfs_file.read
          self.content_type = gridfs_file.content_type
        rescue
          self.status = :file_not_found
          self.content_type = 'text/plain'
          self.response_body = ''
        end
      end
    end

Save this file as `app/controllers/gridfs_controller`. Notice that we're pulling details about the request path directly out of the request. By default, CarrierWave stores files in GridFS under "uploads/filename". Therefore, we need to turn the request path (`/images/uploads/filename`) into a GridFS file path by simply removing the "/images/" (note both slashes). All of these settings are fully configurable in CarrierWave, but that's beyond the scope of this article - just don't forget to modify this controller if you change the url or GridFS storage path.

Now the last part is to set up the route for the image. Open up `config/routes.rb` and add a line for our GridfsController:

    Example::Application.routes.draw do |map|
      match "/images/uploads/*path" => "gridfs#serve"
      resources :things
    end

This maps a url like `/images/uploads/thumb_image.jpg` to the GridfsController's `serve` action.

You should now see an thumbnail image on the show view for the "thing". Congratulations - you're cooking with GridFS now! There's a ton of other cool stuff in Rails 3, CarrierWave, and Mongoid, but this should give you the basics for how to handle uploads with GridFS. Have fun, and let me know if I fucked anything up!