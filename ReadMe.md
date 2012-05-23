# Ewok.js

Yub Nub!

## About

Ewok is a thin layer that pulls together and (optionally) embeds jQuery, Underscore, Settee, and Backbone with simple base classes in the `Ewok` namespace to ease tasks like routing, view and sub-view management, good memory handling for events (external and internal), logging and more.

This is 0.1 version, so it's *very* early and not complete. It's being built with lessons learned from production apps built with Backbone. Docs and examples are forthcoming.

An up to date build of `ewok.js` will always be kept in the repository:

> [https://raw.github.com/darthapo/ewok.js/master/dist/ewok.js](https://raw.github.com/darthapo/ewok.js/master/dist/ewok.js)

## Quick 'n Dirty

Assuming you've included `ewok.js` in your page, you might use it like this (in coffeescript):
    
    class HomeView extends Ewok.View
      templates:
        # in a script tag in the DOM or
        # it can also be a raw template string
        main: '#home_template'
    
    class MyApp extends Ewok.App
      @route '', @use_view(HomeView)
    
    MyApp.run el:'#main_section'

## TODO

- Documentation
- Examples

## Building

Make you sure have the build reqs:

    bundle install

To build `dist/` files:

    rake build

To run the tests, open `test/index.html` in your browser.

To work on tests, run the dev server:

    rake serve

Then visit [http://localhost:4567/test/index.html](http://localhost:4567/test/index.html):

    open http://localhost:4567/test/index.html

(The above will launch your default browser, on a Mac)

Ewok is built with [Gumdrop](https://github.com/darthapo/gumdrop).
