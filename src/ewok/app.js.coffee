# Monkey patch Backbone to try a 404 route if a route isn't found!
# fallback_to_404= (fn, args...)->
#   @lastMatched= no
#   results= fn.apply(this,args)
#   Ewok.log "start or checkUrl:", results, @lastMatched, this
#   @loadUrl('404') unless @lastMatched or results
#   results
# Backbone.History::start= _.wrap Backbone.History::start, fallback_to_404
# Backbone.History::checkUrl= _.wrap Backbone.History::checkUrl, fallback_to_404
# Backbone.History::loadUrl= _.wrap Backbone.History::loadUrl, (lu, args...)->
#   result= lu.apply(this, args)
#   Ewok.log "loadUrl", args, result, @lastMatched, this
#   @lastMatched= yes if result
#   result



class App

  @route: (path, fnOrHash={})->
    @routeMap or= {}
    @routeMap[path]= fnOrHash

  # Route Helper
  @use_view: (ViewClass)->
    enter: (args...)->
      # @app.log "Routed ##{ @path }", @params
      @app.showView ViewClass, { @params }
    leave: (args...)->
      # Ewok.log "Leave #{ @path }!", @
  
  # Route Helper
  @call_method: (fnName)->
    enter: (args...,app)->
      app[fnName](true, args)
    leave: (args...,app)->
      app[fnName](false, args)

  @run: (opts)->
    unless @instance?
      @instance= new @
      @instance.run(opts)
    else
      @instance.log "Already running!"
      @instance

  constructor: ->
    @el or= 'body'
    # logPrefix= if @.constructor.name then "[#{@.constructor.name}]" else '[App]'
    # Ewok.loggable( @, logPrefix)
    @stateMap= @.constructor.stateMap or {}
    @routeMap= @.constructor.routeMap or {}
    @_buildRouter()

  _buildRouter: ->
    # @log "_buildRouter()!", @routeMap, @
    @router= new Backbone.Router()
    r404= null
    for own path,info of @routeMap
      if path is '404'
        @log "Route -> ##{path}", info
        r404= new RouteInfo(@, '.*', info)
        @routeMap[path]= r404 # ???
      else
        @log "Route -> ##{path}", info
        rInfo= new RouteInfo(@, path, info)
        @router.route path, null, @_routeChange(rInfo)
        @routeMap[path]= rInfo # ???
    
    unless r404 is null
      @log "Route -> *", info
      @router.route '.*', null, @_routeChange(r404)
    @

  _willInitialize: =>
    @el= $(@el) if _.isString(@el)
    @initialize() if @initialize
    @fire 'app:init', app:@
    if Backbone.history
      Backbone.history.start() #({ pushState:no })
    else
      @log "No routes defined! Not starting Backbone.history"
    @fire 'app:run'

  _routeChange: (info)->
    (args...)=>
      #@log "Change route to #{info.path} for", @, info, args
      @_currentRoute.doLeave(args) if @_currentRoute
      @_currentRoute= info
      @_currentRoute.doEnter(args)

  # Visit a route, triggering the router to do it's thing
  visit: (path, silent=no)->
    @router.navigate path, trigger:yes, replace:silent

  # Mark your place in the app, updates the URL without triggering the router
  history: (path, silent=no)->
    @router.navigate path, trigger:no, replace:silent

  showView: (view, options={})->
    view = if _.isFunction(view)
      options.app= @
      new view(options)
    else
      view.app= @
      view
    view.render()
    @activeView.close() if @activeView

    @doViewChange(view)
    
    @activeView= view
    view.show()
    @

  doViewChange: (view)->
    @el.html ""
    @el.append view.el

  run: (@options={})->
    @el= @options.el if @options.el
    unless @options.immediate
      $(@_willInitialize)
    else
      @_willInitialize()
    @


namedParamRE= /:\w+/g

class RouteInfo
  constructor: (@app, @path, extra)->
    extra= extra() or {} if _.isFunction(extra)
    for own key,val of extra
      @[key]= val

  enter: -> #stub
  leave: -> #stub

  doEnter: (args)->
    @params= @argsToHash(args)
    args.push @app
    @enter.apply(@, args)

  doLeave: (args)->
    args.push @app
    @leave.apply(@, args)
    @params={}
  
  argsToHash: (args)->
    data={}
    names= @path.match namedParamRE
    _.each names, (name, idx)->
      data[ name.slice(1) ]= args[idx]
    data


Ewok
  .deferLoggable( App::, '[App]')
  .eventable( App:: )
  .exports({ App })
