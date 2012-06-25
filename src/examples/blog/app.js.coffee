## VIEWS

slugify= (text)->
  text
    .toLowerCase()
    .replace(/[^-a-zA-Z0-9,&\s]+/ig, '')
    .replace(/-/gi, "_")
    .replace(/\s/gi, "-")

blam.define 'markdown', (src)->
  marked(src)

blam.define 'layout', ()->
  _(
    header(
      nav(
        a(href:"#", "Home")
        a(href:"#hello/you", "Hello")
        a(href:"#search", "Search")
      )
      h1("Ewok Blog Example")
    )
    article(
      __(arguments)
    )
    footer(
      p("&copy; right now! by you!")
    )
  )


class HomeView extends Ewok.View
  templates:
    main: (posts)->
      layout(
        div.posts()
      )
  initialize: ->
    @collection= Posts
  render: ->
    super()
    @addView PostItemView, model:post for post in Posts.models
      


class PostItemView extends Ewok.View
  templates:
    main: (model)->
      div.post(
        h2.title( 
          a(
            href:"#post/#{ model.slug }"
            model.title 
          )
        )
        div.body(
          markdown(model.body)
        )
      )

  render: ->
    super()
    @parent.$el.find('.posts').append @$el


class PostView extends Ewok.View
  templates:
    main: (post)->
      layout(
        div.post(
          h1( post.title )
          markdown( post.body )
        )
        div.comments(
          h3( "Comments" )
          each(post.comments, (comment)->
            div.comment(
              markdown(comment.body)
            )
          )
        )
      )
  initialize: ->
    results= Posts.where(slug:@params.slug)
    if results.length
      @model= results[0]
    else
      @app.visit('#404', yes)



class HelloView extends Ewok.View
  templates:
    main: (params)->
      layout(
        h2( "Helloo ", params.name ))


class SearchView extends Ewok.View
  events:
    'submit form': 'doSubmit'
  templates:
    main: (params)-> 
      layout(
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
    # @log "html", @$el.html()

  doSubmit: (e)->
    e.preventDefault()
    # @log "DO SUBMIT!", @
    q= @$el.find("#q").val()
    q= if q is "" then "" else "/#{q}"
    @app.visit "search#{ q }"


class FourOhFourView extends Ewok.View
  templates:
    main: (params)->
      layout(
        markdown("""
          ## Not Found!

          Whoops! Sorry that page can't be found! (`#{ params.route }`)
        """)
      )
  initialize: ->
    @params.hash= window.location.hash
    @params.route= window.location.hash.substring(1)
    @log @params


## MODELS
class Post extends Ewok.Model
  initialize: ->
    unless @get('slug')
      @set( slug:slugify( @get('title') ) )
  comments: ->
    @_commentCol or= Comments.liveFilter(post_id:@id)
  toJSON: ->
    val= super()
    val.comments= @comments().toJSON()
    val
class PostCollection extends Ewok.Collection
  model: Post

class Comment extends Ewok.Model
  post: -> Posts.where id:@get('post_id')
class CommentCollection extends Ewok.Collection
  model:Comment

## APP (and routes)
class @TestApp extends Ewok.App
  
  @route '', @use_view(HomeView)

  @route 'post/:slug', @use_view(PostView)

  @route 'hello/:name', @use_view(HelloView)

  @route 'search', @use_view(SearchView)
  @route 'search/:q', @use_view(SearchView)

  @route '404', @use_view(FourOhFourView)


TestApp.run el:'body'


@Posts= new PostCollection()

Posts.add title:"Post 1", body:"I've got stuff to say!", id:_.uniqueId()
Posts.add title:"Post 2", body:"I always have stuff to say!", id:_.uniqueId()
Posts.add title:"Important Post", body:"POOOT", id:_.uniqueId()

@Comments= new CommentCollection()

Comments.add post_id:0, body:"Alex, what the *hell* is going on?"

