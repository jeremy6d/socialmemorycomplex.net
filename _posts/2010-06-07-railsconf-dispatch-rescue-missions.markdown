---
title: RailsConf Dispatch - Rescue Missions
subtitle: Tammer Saleh on parachuting into disaster codebases
tags: railsconf refactoring development ruby rails
---
The first tutorial class at [RailsConf](http://en.oreilly.com/rails2010) on [Rails Anti-Patterns](http://s3.amazonaws.com/tammer_saleh/production/assets/vtm_rails_antipatterns.pdf) has been phenomenal and incredibly validating given my experiences with consulting. [Tammer Saleh](http://tammersaleh.com/) gave a wonderful talk on how to handle troubled legacy codebases - what he calls "rescue missions". It's particularly relevant for me as much of my early freelance work centered on failing projects I was dumped into. 

Because of the success of Rails, there's a lot of shitty code out there for you to fix. The harder issue is figuring out why shitty code was delivered, which can be trickier to figure out than you'd think. It can be really difficult to change the course of a project when much more than merely the code is dysfunctional.

Tammer suggested a ton of coping strategies, many of which end up being good practices for most situations. I'm sharing my cursory notes here in case others are interested. Feel free to strike up a conversation in the comments to explore these points. I'll link to the slides when they become available.

* Considering a code rescue mission
  * client relationships can be adversarial
  * many problems are with process and not just programming, where the programmer didn't push back on features
  * when devs don't want to follow convention, disaster often ensues
  * _15 min code review_ to get clear on situation before contract signed
    * models
      * how many models? Too many is bad.
      * search for "assert_true" to see where scaffolding was used
      * empty models
      * superfluous raw SQL
    * controllers
      * non-RESTful controllers
      * pseudo-validations in create actions (manual checks in actions not using conventions but inline)
      * monolithic controllers (three controllers & a zillion actions)
      * custom authentication
    * views
      * PHP-style inline ruby / SQL in the views
      * inconsistent file structure
      * poor markup, no rails helpers involved
      * layout code in views
      * duplication - too DRY can be bad, but duplication should be avoided
    * lib
      * reinventing the wheel
      * duck punching - reopening class
    * general danger signs
      * huge files
      * feature bloat
      * bad ruby style
      * gratuitous metaprogramming
   * Once you've concluded this is a rescue mission, identify its root causes - it's never about the code itself
      * hard technical problems
      * poor developers - hard to identify, you can't judge from the code necessarily
      * process reasons
      * personality reasons
        * a lack of focus on quality
        * artificial deadlines
  * think carefully about taking the job
    * reputation damage likely
    * client probably doesn't have much money left
    * Core question: _can you fix this?_ Not just the code but client issues that caused bad code.
    * Will fixing this result in future good work?
    * How much money? This is painful, difficult, and risky work - you should be well paid. Rule of thumb: 50% over base.
* Proceeding with the rescue mission
  * train the client
    * all of the work you do on the code is useless if the client keeps their bad habits
    * send them the 37 signals book, dog-ear pages to pay attention to
    * my job is not to be just a code monkey. I'm here for _advice and negotiation on features_. Push back!
    * force payment of tech debt
      * explain long term costs
      * 70-80% of core development budget
    * you must be willing to lose the client
  * fix process
    * establish trust
    * record everything 
      * transcript, voice recording, etc.
      * documentation for yourself
      * communication
      * _visibility_
    * weekly standups
    * tools
      * github - get client subscribed to commit feed for visibility (they don't need to understand)
      * pivotal tracker
        * client prioritization of stories
        * emergent velocity is crucial
        * _use low velocity as an argument for fixing tech debt_
      * basecamp & campfire for communication
  * fix codebase
    * peer programming
      * transfer domain knowledge
      * teaches best practices
      * keeps you focused
    * integration tests are a necessity on rescue missions
      * cover common paths
      * _integration tests for existing behavior, functional/unit tests for added or modified behavior_
    * work in small chunks, mixing in:
      * client value
      * low impact, high yield pieces
      * reduce tech debt
    * focus on issues _slowing you down_
    * DON'T GET DISTRACTED by all the issues, just record them and move on
      * don't do code comments, because client can't see that
    * _remote tracking_ feature branches
      * isolate refactoring
      * increase visibility
      * protects you from rabbit hole excursions - you can always trash the whole thing
      * git remote branch gem available
    * balance of refactorings w/ features
* Other field tactics
  * Too many models
    * consider a much more denormalized model than often desired
    * it's never just one more model to throw in
    * _extra code is a liability_