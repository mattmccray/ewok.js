# Ewok.js

Yub Nub!

## About

Ewok is a thin layer that pulls together and (optionally) embeds jQuery, Underscore, Hogan, and Backbone with simple base classes in the `Ewok` namespace to ease tasks like routing, view and sub-view management, good memory handling for events (external and internal), logging and more.

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

- Add unit tests
- Documentation
- Examples

## Building

Ewok is built with [Gumdrop](https://github.com/darthapo/gumdrop).

In theory, just run `bundle install`, then `rake build` it. More/better instructions soon.