
describe "Ewok", ->
  describe 'LiveCollection', ->
    it "should exist", ->
      expect(Ewok.LiveCollection).to.not.be.undefined
      # etc...


    it "should auto-update with filter hash", ->
      class Post extends Ewok.Model
        initialize: -> @comments= Comments.liveFilter post_id:@id
      class Comment extends Ewok.Model
        post: -> Posts.where id:@get('post_id')
      class PostCollection extends Ewok.Collection
        model: Post
      class CommentCollection extends Ewok.Collection
        model: Comment

      Posts= new PostCollection
      Comments= new CommentCollection
      
      Posts.add title:'First', id:1
      Posts.add title:'Second', id:2

      Comments.add title:'For First', id:1, post_id:1
      Comments.add title:'Another for First', id:2, post_id:1

      p= Posts.get 1

      expect(p.comments.length).to.equal 2

      Comments.add title:'Yet Another for First', id:3, post_id:1

      expect(p.comments.length).to.equal 3
      expect(Posts.get(2).comments.length).to.equal 0


    it "should auto-update with filter function ", ->
      class Post extends Ewok.Model
        initialize: ->  @comments= Comments.liveFilter @commentFilter, fields:'post_id'
        commentFilter: (m)=> m.get('post_id') == @id
      class Comment extends Ewok.Model
        post: -> Posts.where id:@get('post_id')
      class PostCollection extends Ewok.Collection
        model: Post
      class CommentCollection extends Ewok.Collection
        model: Comment

      Posts= new PostCollection
      Comments= new CommentCollection
      
      Posts.add title:'First', id:1
      Posts.add title:'Second', id:2

      Comments.add title:'For First', id:1, post_id:1
      Comments.add title:'Another for First', id:2, post_id:1

      p= Posts.get 1

      expect(p.comments.length).to.equal 2

      Comments.add title:'Yet Another for First', id:3, post_id:1

      expect(p.comments.length).to.equal 3
      expect(Posts.get(2).comments.length).to.equal 0

    