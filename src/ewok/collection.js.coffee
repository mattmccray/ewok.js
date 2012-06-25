
class Collection extends Backbone.Collection

  liveFilter: (filter, options)->
    new LiveCollection this, filter, options



# new LiveCollection( sourceCollection, filter, [options])
#
# `filter` can be an object (uses collection#where to filter) or a 
# function (uses collection#filter to filter). If you pass a function
# you can optimize which fields to filter on by passing in a `fields`
# array in `options`.
#
class LiveCollection extends Backbone.Collection

  constructor: (@_source, @_filter={}, @options={})->
    throw "Requires source collection!" unless @_source
    if @options.comparator or @_source.comparator
      @options.comparator = @options.comparator or @_source.comparator 
    
    filter_type= if _.isFunction(@_filter) then 'Fn' else 'Obj'
    @[method]= @[method+filter_type] for method in ['_runFilter', '_bindFields', '_unbindFields', '_matchesFilter'] 

    super @_runFilter(), @options
    @start false

  update: ->
    @reset @_runFilter()

  stop: ->
    @_source
      .off('add', @_didAddModel, this)
      .off('remove', @_didRemoveModel, this)
      .off('reset', @_didResetModels, this)
    @_unbindFields()
    @

  start: (auto_update=true)->
    @_source
      .on('add', @_didAddModel, this)
      .on('remove', @_didRemoveModel, this)
      .on('reset', @_didResetModels, this)
    @_bindFields()
    @update() if auto_update
    @
  
  _didAddModel: (model, col, options)->
    @add model, at:options.index if @_matchesFilter model

  _didRemoveModel: (model, col)->
    @remove model 
  
  _didResetModels: (col)->
    @update()

  _fieldDidChange: (model)->
    if @_matchesFilter model
      # index= @_source.indexOf(model) # This won't really work right, will it?
      # @add model, at:index
      @add model
    else
      @remove model

  _runFilterObj: ->
    @_source.where(@_filter)

  _bindFieldsObj: ->
    for own key,val of @_filter
      @_source.on("change:#{ key }", @_fieldDidChange, this)
    @

  _unbindFieldsObj: ->
    for own key,val of @_filter
      @_source.off("change:#{ key }", @_fieldDidChange, this)
    @

  _matchesFilterObj: (model)->
    for own key,target of @_filter
      return no if target != model.get key
    return yes

  _runFilterFn: ->
    @_source.filter(@_filter)

  _bindFieldsFn: ->
    if _.isArray(@options.fields)
      for field in @options.fields
        @_source.on("change:#{ field }", @_fieldDidChange, this)
    else
      @_source.on("change", @_fieldDidChange, this)

  _unbindFieldsFn: ->
    if _.isArray(@options.fields)
      for field in @options.fields
        @_source.off("change:#{ field }", @_fieldDidChange, this)
    else
      @_source.off("change", @_fieldDidChange, this)

  _matchesFilterFn: (model)->
    @_filter(model)


Ewok
  .deferLoggable(Collection::, '[Collection]')
  .deferLoggable(LiveCollection::, '[LiveCollection]')
  .exports { Collection, LiveCollection }
