--- 
wordpress_id: 940
title: The RSpec post (including an important tip on shared example groups)
wordpress_url: http://blog.6thdensity.net/?p=940
layout: post
---
<p>So in my Rails apps lately I've been using the hell out of some <a href="http://rspec.info">RSpec</a>.  I have to say that it's making me a better, more methodical coder.  It's not just allowing me to define my app <a href="http://behaviour-driven.org/">in terms of expected behaviors</a> and providing the well understood regression testing capabilities of <a href="http://www.ruby-doc.org/stdlib/libdoc/test/unit/rdoc/index.html">any testing framework</a>. It's a whole new way of organizing my approach to programming.</p><p>First of all, starting a large application can seem daunting.  To paraphrase Rumsfeld, we don't know what we don't know half the time - so many different features, so much complexity in the way domain objects interract, and the coder inevitably drops a ball juggling all this in his head.  Add to this uncertainty the inevitable course corrections by the client, and it's no wonder we lose a lot of sleep during the big pushes to get the foundations of our applications written.</p><p>By starting out writing specifications - and not as "business analysts" per se, but rather as programmers who are taking a moment to analyze what real world problems we're trying to solve - we give ourselves a sort of technical permission to begin with a 10,000 foot view and build a structured path down to the ground level, step by behavior driven step. The way the application gets used really should only be considered at whatever level of detail makes sense at a particular stage in the development cycle (the insight of the <a href="http://agilemanifesto.org/">agile school</a>).</p><p><!--more-->Throughout my "spec'ed" apps I have lots of "pending" specification cases.  These are just placeholders to allow me to talk about future functionality I don't yet want to implement.  It's remarkably freeing to be able to simply record what you want the code to do in plain English, worrying about the implementation later. You're basically giving yourself a "plan of attack" without being slowed down by how the attack will actually take place - remember, we're worried at this point about simply defining what behavior we should expect, not how that behavior will come about (also see <a href="http://blog.6thdensity.net/?p=940#comment-96149">the comments</a> - you can simply omit the block altogether).<blockquote><pre lang="ruby">describe Bulletin, "when being composed" do
  
  it "should be valid with all fields filled in" do
    pending
  end

  it "should require a title" do
    pending
  end
  
  it "should require a body" do
    pending
  end
  
  it "should require an author" do
    pending
  end
  
  it "should require a valid author" do
    pending
  end
end</pre></blockquote></p><p>Once I've worked out a plan about how this code will behave, I can write a test inside each individual specification block.  By writing the test first, seeing the test fail, then implementing the code that makes the test pass, I break a big problem into bite size chunks.  I'm also being forced to "think ahead" about what I want to accomplish - thereby discovering edge cases that might complicate my original plan of attack.  I cannot overstate the utility of thinking about what your code does in terms of tests.<blockquote><pre lang="ruby">describe Bulletin, "when being composed" do
  
  fixtures :volunteers
  
  before(:each) do
    @bulletin = Bulletin.new( :body => "Random body text",
                              :title => "the title of the post",
                              :author_id => volunteers(:quentin).id)
  end
  
  it "should be valid with all fields filled in" do
    @bulletin.should be_valid
  end

  it "should require a title" do
    @bulletin.title = nil
    @bulletin.should_not be_valid
  end</pre></blockquote></p><p>The nested describe blocks redefined my whole approach to rspec.  As you've seen, before blocks allow you do shared setup for a group of tests.  Well, you can share these before blocks among several different types of describe blocks, and the description texts just build on one another.  This allows you to organize the spec in a readable and DRY form, factoring out mere setup steps to expose the more readable business logic.<blockquote><pre lang="ruby">  describe "when attempting to edit a comment" do
    
    before(:each) do
      @bulletin = bulletins(:the_first_one)
      @try_to_get_an_edit_form = lambda { get :edit, 
                                              :member_id => @author_of_the_note.member_url, 
                                              :trade_note_id => @the_note.id, 
                                              :id => @comment.id }
    end

    describe "by somebody other than the comment's author or an administrator" do          
      before(:each) do
        login_as(:some_other_guy)
        @try_to_get_an_edit_form
      end
      
      it "should not successfully load the edit page" do 
        response.should_not be_success
      end
      
      it "should display an error message" do
        puts flash.inspect
        flash[:warning].should == "Unauthorized action."
      end
    end
  
    describe "by an administrator" do
      before(:each) do
        login_as(:admin)
        @try_to_get_an_edit_form
      end
...</pre></blockquote></p><p>The next step from that was getting to shared example groups.  This feature allows you to define an example group containing specified behavior that can be shared by multiple subsequent specifications.  Take the example of a feature that allows certain user roles to edit a post, but not others.  Instead of repeating the expectation for each role's specification, you can define a set of expectations that apply to a certain class of behavior:<blockquote><pre lang="ruby">describe "an allowable edit", :shared => true do

  it "should render the edit template" do
    response.should render_template('edit')
  end
end</pre></blockquote>Then just reference that each role should behave like that example group:<blockquote><pre lang="ruby">describe "by an administrator" do
  before(:each) do
    login_as(:admin)
      @try_to_get_an_edit_form
    end
      
  it_should_behave_like "an allowable edit"
end</pre></blockquote></p><p>Now, it took me a long time to get RSpec to play nice with shared example groups, because I had gotten so used to heavily nested describe blocks that I wanted to include the shared example groups in these blocks.  <em>That will not work.</em>  You need to put all your shared example groups outside of <em>any</em> describe blocks.  They also need to be run before they can be used, so I put them at the top</p><p>I know there's a way to load shared examples from separate file, allowing you to bounce behaviors throughout your specs, but I haven't gotten there yet (I hope to discover <a href="http://rspec.info/documentation/stories.html">RSpec Stories</a> soon as well, which promise an even more natural language way to specify behavior).  Suffice to say, this is power enough for me now.  As somebody who gets easily overwhelmed and distracted, the focus that behavior driven development gives me is priceless.  I also appreciate being able to have an intermediate layer between the technical implementation frame of mind and the human-useable functionality frame-of-mind.  It's about a process that manages the monster you're creating, and I know few programmers who wouldn't benefit from the type of programming RSpec encourages.</p>
