class Notes
  # initialize: ->
  #   @comments= Comments.liveFilter note_id:@id

  comments: ->
    @_comments or= Comments.liveFilter note_id:@id
    @_comments


class Document extends Ewok.Model
  
  children: ->
    Documents.filter(parent_id:@id)


class DocumentCollection extends Ewok.Collection
  model: Document

  rootDocs: ->
    @liveFilter parent_id:null


@Documents= new DocumentCollection()

new_doc= (name, attrs={})->
  attrs.id= _.uniqueId()
  attrs.name= name #"#{ name } - #{ attrs.id }"
  attrs.parent_id= null unless attrs.parent_id?
  attrs

Documents.add new_doc("First", position:0)
Documents.add new_doc("Second", position:1)
Documents.add new_doc("Third", position:2)
Documents.add new_doc("Fourth", position:3)
Documents.add new_doc("Fifth", position:4)

Documents.add new_doc("First x Child", position:0, parent_id:0)
Documents.add new_doc("Second x Child", position:0, parent_id:2)

class HomeView extends Ewok.View

  templates:
    main: -> _(
      div.treeview()
      div.list-container()
      div.list-container2()
    )

  initialize: ->
    @rootDocs= Documents.rootDocs()

    @listview_subset= new ListView collection:@rootDocs, itemView:DocumentListItem
    @listview = new ListView collection:Documents, itemView:DocumentListItem, moveElements:yes
    @listview2 = new ListView collection:Documents, itemView:DocumentListItem #, allowDropInto:yes

  render: ->
    super()
    @tree= @$el.find('.treeview')
    self= @

    @listview_subset.render()
    @listview.render()
    @listview2.render()

    @$el.find('.treeview').append @listview_subset.el
    @$el.find('.list-container').append @listview.el
    @$el.find('.list-container2').append @listview2.el


class ListView extends Ewok.View
  className: 'list-view'

  events:
    'draginit .list-item': 'onDragInit'
    'dragend .list-item':  'onDragEnd'
    'dropover .list-item': 'onDropOver'
    'dropmove .list-item': 'onDropMove'
    'dropon .list-item':   'onDropOn'
    'dropout .list-item':  'onDropOut'

  initialize: ->
    @viewClass= @options.itemView
    throw "ListView requires collection and itemView!" unless @collection? and @viewClass?
    @itemCollection= new Ewok.Collection()
    @srcDidChange()

    @attach @collection,
      'add':    'srcDidChange'
      'remove': 'srcDidChange'
      'reset':  'srcDidChange'

    @attach @itemCollection,
      'add':    'render'
      'remove': 'render'
      'reset':  'render'

  srcDidChange: ->
    @itemCollection.reset @collection.models

  render: ->
    @closeChildViews()
    @$el.html ""
    for model in @itemCollection.models
      container= $('<div class="list-item"></div>')
      view= @addView @viewClass, model:model, listview:this
      container.append view.el
      container.data 'list-view', this
      @$el.append container
    @

  onDragInit: (ev, drag)->
    drag.element.addClass 'is-moving'
    drag.ghost().addClass 'is-ghosted'
      # drag.vertical()

  onDragEnd: (ev, drag)->
    drag.element.removeClass 'is-moving'
    @

  onDropOver: (ev, drop, drag)->
    el= drop.element
    if el.hasClass('is-moving') or el.data('list-view') isnt drag.element.data('list-view')
      drop.cancel()
      el.removeClass 'is-droppable'
    else
      el.addClass 'is-droppable'

  onDropMove: (ev, drop, drag)->
    if (el= drop.element).hasClass 'is-droppable'
      @_drawDragMarkers el, ev, drop, drag

  onDropOut: (ev, drop, drag)->
    if (el= drop.element).hasClass 'is-droppable'
      @_removeDropClasses el

  onDropOn: (ev, drop, drag)->
    if (el= drop.element).hasClass 'is-droppable'
      drag_el= drag.element
      [drag_idx,drop_idx]= @_getItemIndexTuple(drag_el, el)

      if el.hasClass 'move-above'
        new_idx= drop_idx - 1
        new_idx= new_idx - 1

      else if el.hasClass 'move-below'
        new_idx= drop_idx #+ 1
        new_idx= new_idx - 1

      else if el.hasClass 'move-under'
        @log "Move into --- ?", drag_el, drag_el
        new_idx= false

      else
        new_idx= false

      if new_idx isnt false
        new_idx= new_idx + 2 if drag_idx > drop_idx
        new_idx= 0 if new_idx < 0
        model= drag_el.children().view().model
        @itemCollection.remove model, silent:true
        @itemCollection.add model, at:new_idx
      
      else
        @_removeDropClasses el

  _getItemIndexTuple:(el_a, el_b)->
    [ @_getItemIndex(el_a), @_getItemIndex(el_b)]

  _getItemIndex:(el)->
    @$el.find('.list-item').index(el)


  _drawDragMarkers: (el, ev, drop, drag)->
      height= el.outerHeight()
      pos= el.offset()
      top= pos.top
      diff= ev.pageY - top
      half= Math.floor height / 2
      posStr= if diff < half
          'top'
        else
          'bottom'
      # quads= Math.floor height / 4
      # posStr= if diff < quads
      #     'top'
      #   else if diff < (quads * 3) and @options.allowDropInto
      #     'mid'
      #   else
      #     'bottom'
      el.toggleClass 'move-above', (posStr is 'top')
      # el.toggleClass 'move-under', (posStr is 'mid')
      el.toggleClass 'move-below', (posStr is 'bottom')

  _removeDropClasses: (el)->
    el.removeClass 'is-droppable'
    el.removeClass 'move-above'
    el.removeClass 'move-under'
    el.removeClass 'move-below'



class DocumentListItem extends Ewok.View

  templates:
    main: (model)-> 
      div.name(
        model.id
        ". "
        model.name
      )

  initialize: ->
    @attach @model,
      'change:name': @render





class TestApp extends Ewok.App
  @route '', @use_view(HomeView)


TestApp.run el:'body'

@TestApp= TestApp