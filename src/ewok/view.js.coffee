
class View extends Backbone.View

  # templates: {}

  # _attached: []
  # _views: []

  constructor: (options)->
    @templates[name]= @fetchTemplate(path) for own name,path of @templates if @templates
    super options
    # @log "CONSTRUCTED!"

  _configure: (options)->
    super options
    @parent= @options.parent if @options.parent
    @params= @options.params if @options.params
    @app= @options.app if @options.app
    @id= @cid unless @id
    @className = "ewok-view" unless @className

  setElement: (element, delegate)->
    super element, delegate
    @$el.data('view', @)
    @

  attach: (target, events) ->
    @_attached or= []
    for own event,callback of events
      target.on event, callback
      @_attached.push {target,event,callback}
    @
  
  detach: ->
    item.target.off(item.event, item.callback) for item in @_attached if @_attached
    @_attached=[]
    @

  addView: (view, atts={})->
    @_views or= []
    view= new view(atts) if _.isFunction(view)
    view.parent= @
    @_views.push view
    view.render(@) # ???
    view

  close: ->
    @unbind()
    @detach()
    view.close() for view in @_views if @_views
    @$el.data('view', null)
    @remove()
    @onClose() if @onClose
    # @log "CLOSED"
    @

  # Doesn't call the Ewok.loggable code until it's first used.
  log: (args...)->
    logPrefix= if @.constructor.name then "[#{@.constructor.name}]" else '[View]'
    Ewok.loggable( @, logPrefix)
    @['log'].apply(@, args)
  
  show: ->
    @onShow() if @onShow
    # @log "SHOWN"
    @

  render: ->
    if @templates.main
      data= if @model?
        if @model.toJSON
          @model.toJSON()
        else
          @model
      else if @params
        @params
      else if @collection
        items:@collection.toJSON()
      else
        {}
      @$el.html @templates.main.render(data)

  fetchTemplate: (path)->
    # @log "fetchTemplate", path, @
    if _.isString path
      Ewok.fetchTemplate path
    else
      # If it's not a string, it's probably already compiled!
      path
      


Ewok.exports { View }


$.fn.view= ->
  view= null
  parent= $(this)
  while !view and parent.length > 0
    view= parent.data('view')
    parent= parent.parent() if !view
  view


###
  TESTING
##


class TestView extends Ewok.View

  templates:
    main: 'path/to/template'

  initialize: ->
    @attach app, notify:@appNotification

    @attach @model,
      change: @modelChanged
      remove: @modelRemoved
      add:    @modelAdded

  render: ->
    @$el.html( @templates.main() )

    for item in @data
      @addView SubView, model:item


class SubView extends Ewok.View
  
  templates:
    main: 'path/to/template/item'
  
  render: ->
    @$el.html @templates.main(@model.toJSON())
    @parent.find('.container').append(@el)