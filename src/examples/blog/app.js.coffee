## VIEWS

class HomeView extends Ewok.View
  templates:
    main: (posts)->
      div(
        h2("Home")
        div( class:'posts cats' )
        ul(
          each(posts, (post)->
            li( post.title )
          )
        )
      )

  render: ->
    content= @templates.main(@app.posts.toJSON())
    @log "Rendered:", content
    @$el.html content
    @app.posts.each (post)=>
      @addView PostView, model:post


class PostView extends Ewok.View
  templates:
    main: (model)->
      dl(
        dt(model.title)
        dd(model.body)
        hr())

  render: ->
    content= @templates.main(@model.toJSON())
    @log "Rendered:", content, @model.toJSON()
    @$el.html content
    @parent.$el.find('.posts').append @$el


class HelloView extends Ewok.View
  templates:
    main: (params)->
      div(
        h2( "Helloo ", params.name ))


class SearchView extends Ewok.View
  events:
    'submit form': 'doSubmit'
  templates:
    main: (params)-> 
      _(
        form(
          input( type:'search', id:'q', value:(params.q or "") )
          (button "Go"))
        (->
          if params.q
            div(
              h2("Searching for: ", params.q))
        )
      )

  render: ->
    @params.q= "" unless @params.q
    super()
    @log "html", @$el.html()

  doSubmit: (e)->
    e.preventDefault()
    @log "DO SUBMIT!", @
    @app.visit "search/#{ @$el.find("#q").val() }"


## MODELS
class Post extends Ewok.Model

class PostCollection extends Ewok.Collection
  model: Post


## APP (and routes)
class @TestApp extends Ewok.App
  
  @route '', @use_view(HomeView)

  @route 'hello/:name', @use_view(HelloView)

  @route 'search', @use_view(SearchView)
  @route 'search/:q', @use_view(SearchView)

  initialize: ->
    @posts= new PostCollection()
    data= []
    data.push title:"Post 1", body:"I've got stuff to say!"
    data.push title:"Post 2", body:"I always have stuff to say!"
    data.push title:"Important Post", body:"POOOT"
    @posts.reset data


TestApp.run el:'#main_section'
