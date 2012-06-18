(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  describe("Ewok", function() {
    return describe('LiveCollection', function() {
      it("should exist", function() {
        return expect(Ewok.LiveCollection).to.not.be.undefined;
      });
      it("should auto-update with filter hash", function() {
        var Comment, CommentCollection, Comments, Post, PostCollection, Posts, p;
        Post = (function(_super) {

          __extends(Post, _super);

          function Post() {
            return Post.__super__.constructor.apply(this, arguments);
          }

          Post.prototype.initialize = function() {
            return this.comments = Comments.liveFilter({
              post_id: this.id
            });
          };

          return Post;

        })(Ewok.Model);
        Comment = (function(_super) {

          __extends(Comment, _super);

          function Comment() {
            return Comment.__super__.constructor.apply(this, arguments);
          }

          Comment.prototype.post = function() {
            return Posts.where({
              id: this.get('post_id')
            });
          };

          return Comment;

        })(Ewok.Model);
        PostCollection = (function(_super) {

          __extends(PostCollection, _super);

          function PostCollection() {
            return PostCollection.__super__.constructor.apply(this, arguments);
          }

          PostCollection.prototype.model = Post;

          return PostCollection;

        })(Ewok.Collection);
        CommentCollection = (function(_super) {

          __extends(CommentCollection, _super);

          function CommentCollection() {
            return CommentCollection.__super__.constructor.apply(this, arguments);
          }

          CommentCollection.prototype.model = Comment;

          return CommentCollection;

        })(Ewok.Collection);
        Posts = new PostCollection;
        Comments = new CommentCollection;
        Posts.add({
          title: 'First',
          id: 1
        });
        Posts.add({
          title: 'Second',
          id: 2
        });
        Comments.add({
          title: 'For First',
          id: 1,
          post_id: 1
        });
        Comments.add({
          title: 'Another for First',
          id: 2,
          post_id: 1
        });
        p = Posts.get(1);
        expect(p.comments.length).to.equal(2);
        Comments.add({
          title: 'Yet Another for First',
          id: 3,
          post_id: 1
        });
        expect(p.comments.length).to.equal(3);
        return expect(Posts.get(2).comments.length).to.equal(0);
      });
      return it("should auto-update with filter function ", function() {
        var Comment, CommentCollection, Comments, Post, PostCollection, Posts, p;
        Post = (function(_super) {

          __extends(Post, _super);

          function Post() {
            this.commentFilter = __bind(this.commentFilter, this);
            return Post.__super__.constructor.apply(this, arguments);
          }

          Post.prototype.initialize = function() {
            return this.comments = Comments.liveFilter(this.commentFilter, {
              fields: 'post_id'
            });
          };

          Post.prototype.commentFilter = function(m) {
            return m.get('post_id') === this.id;
          };

          return Post;

        })(Ewok.Model);
        Comment = (function(_super) {

          __extends(Comment, _super);

          function Comment() {
            return Comment.__super__.constructor.apply(this, arguments);
          }

          Comment.prototype.post = function() {
            return Posts.where({
              id: this.get('post_id')
            });
          };

          return Comment;

        })(Ewok.Model);
        PostCollection = (function(_super) {

          __extends(PostCollection, _super);

          function PostCollection() {
            return PostCollection.__super__.constructor.apply(this, arguments);
          }

          PostCollection.prototype.model = Post;

          return PostCollection;

        })(Ewok.Collection);
        CommentCollection = (function(_super) {

          __extends(CommentCollection, _super);

          function CommentCollection() {
            return CommentCollection.__super__.constructor.apply(this, arguments);
          }

          CommentCollection.prototype.model = Comment;

          return CommentCollection;

        })(Ewok.Collection);
        Posts = new PostCollection;
        Comments = new CommentCollection;
        Posts.add({
          title: 'First',
          id: 1
        });
        Posts.add({
          title: 'Second',
          id: 2
        });
        Comments.add({
          title: 'For First',
          id: 1,
          post_id: 1
        });
        Comments.add({
          title: 'Another for First',
          id: 2,
          post_id: 1
        });
        p = Posts.get(1);
        expect(p.comments.length).to.equal(2);
        Comments.add({
          title: 'Yet Another for First',
          id: 3,
          post_id: 1
        });
        expect(p.comments.length).to.equal(3);
        return expect(Posts.get(2).comments.length).to.equal(0);
      });
    });
  });

}).call(this);
