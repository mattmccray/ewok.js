
(function(){var can_apply_log,getTemplateContent,has_console,logger,__slice=[].slice;has_console=window.console&&console.log?true:false;can_apply_log=(function(){try{console.log.apply(console,["[Ewok] waking up..."]);return true;}catch(ex){console.log("NOPE!",ex);return false;}})();logger=function(prefix){var con;con={};con.log=has_console?can_apply_log?function(){var args;args=1<=arguments.length?__slice.call(arguments,0):[];args.unshift(prefix);return console.log.apply(console,args);}:function(){var arg,args,_i,_len,_results;args=1<=arguments.length?__slice.call(arguments,0):[];console.log(prefix);_results=[];for(_i=0,_len=args.length;_i<_len;_i++){arg=args[_i];_results.push(console.log(arg));}
return _results;}:function(){};return con;};getTemplateContent=function(path){if(path.charAt(0)==="#"){return $(path).text();}else{return path;}};this.Ewok={VERSION:"0.1.1",exports:function(methods){_.extend(this,methods);return this;},eventable:function(obj){_.extend(obj,Backbone.Events);obj.fire=obj.trigger;return this;},loggable:function(obj,prefix){if(prefix==null){prefix="";}
_.extend(obj,logger(prefix));return this;},fetchTemplate:(function(has_hogan){if(has_hogan){return function(idOrTmpl){return Hogan.compile(getTemplateContent(idOrTmpl));};}else{return function(idOrTmpl){return _.template(getTemplateContent(idOrTmpl));};}})(typeof Hogan!=="undefined"&&Hogan!==null)};Ewok.loggable(Ewok);Ewok.eventable(Ewok);}).call(this);(function(){var App,RouteInfo,namedParamRE,__bind=function(fn,me){return function(){return fn.apply(me,arguments);};},__slice=[].slice,__hasProp={}.hasOwnProperty;App=(function(){App.route=function(path,fnOrHash){if(fnOrHash==null){fnOrHash={};}
this.routeMap||(this.routeMap={});return this.routeMap[path]=fnOrHash;};App.use_view=function(ViewClass){return{enter:function(){var args;args=1<=arguments.length?__slice.call(arguments,0):[];return this.app.showView(ViewClass,{params:this.params});},leave:function(){var args;args=1<=arguments.length?__slice.call(arguments,0):[];}};};App.call_method=function(fnName){return{enter:function(){var app,args,_i;args=2<=arguments.length?__slice.call(arguments,0,_i=arguments.length-1):(_i=0,[]),app=arguments[_i++];return app[fnName](true,args);},leave:function(){var app,args,_i;args=2<=arguments.length?__slice.call(arguments,0,_i=arguments.length-1):(_i=0,[]),app=arguments[_i++];return app[fnName](false,args);}};};App.run=function(opts){if(this.instance==null){this.instance=new this;return this.instance.run(opts);}else{this.instance.log("Already running!");return this.instance;}};function App(){this._willInitialize=__bind(this._willInitialize,this);var logPrefix;this.el||(this.el='body');logPrefix=this.constructor.name?"["+this.constructor.name+"]":'[App]';Ewok.loggable(this,logPrefix);this.stateMap=this.constructor.stateMap||{};this.routeMap=this.constructor.routeMap||{};this._buildRouter();}
App.prototype._buildRouter=function(){var info,path,rInfo,_ref;this.router=new Backbone.Router();_ref=this.routeMap;for(path in _ref){if(!__hasProp.call(_ref,path))continue;info=_ref[path];rInfo=new RouteInfo(this,path,info);this.router.route(path,null,this._routeChange(rInfo));this.routeMap[path]=rInfo;}
return this;};App.prototype._willInitialize=function(){if(_.isString(this.el)){this.el=$(this.el);}
if(this.initialize){this.initialize();}
this.fire('app:init',{app:this});if(Backbone.history){Backbone.history.start();}else{this.log("No routes defined! Not starting Backbone.history");}
return this.fire('app:run');};App.prototype._routeChange=function(info){var _this=this;return function(){var args;args=1<=arguments.length?__slice.call(arguments,0):[];if(_this._currentRoute){_this._currentRoute.doLeave(args);}
_this._currentRoute=info;return _this._currentRoute.doEnter(args);};};App.prototype.visit=function(path,silent){if(silent==null){silent=false;}
return this.router.navigate(path,{trigger:true,replace:silent});};App.prototype.history=function(path,silent){if(silent==null){silent=false;}
return this.router.navigate(path,{trigger:false,replace:silent});};App.prototype.showView=function(view,options){if(options==null){options={};}
view=_.isFunction(view)?(options.app=this,new view(options)):(view.app=this,view);view.render();if(this.activeView){this.activeView.close();}
this.el.html("");this.el.append(view.el);this.activeView=view;view.show();return this;};App.prototype.run=function(options){this.options=options!=null?options:{};if(this.options.el){this.el=this.options.el;}
if(!this.options.immediate){$(this._willInitialize);}else{this._willInitialize();}
return this;};return App;})();namedParamRE=/:\w+/g;RouteInfo=(function(){function RouteInfo(app,path,extra){var key,val;this.app=app;this.path=path;if(_.isFunction(extra)){extra=extra()||{};}
for(key in extra){if(!__hasProp.call(extra,key))continue;val=extra[key];this[key]=val;}}
RouteInfo.prototype.enter=function(){};RouteInfo.prototype.leave=function(){};RouteInfo.prototype.doEnter=function(args){this.params=this.argsToHash(args);args.push(this.app);return this.enter.apply(this,args);};RouteInfo.prototype.doLeave=function(args){args.push(this.app);this.leave.apply(this,args);return this.params={};};RouteInfo.prototype.argsToHash=function(args){var data,names;data={};names=this.path.match(namedParamRE);_.each(names,function(name,idx){return data[name.slice(1)]=args[idx];});return data;};return RouteInfo;})();Ewok.eventable(App.prototype).exports({App:App});}).call(this);(function(){var View,__hasProp={}.hasOwnProperty,__extends=function(child,parent){for(var key in parent){if(__hasProp.call(parent,key))child[key]=parent[key];}function ctor(){this.constructor=child;}ctor.prototype=parent.prototype;child.prototype=new ctor();child.__super__=parent.prototype;return child;},__slice=[].slice;View=(function(_super){__extends(View,_super);function View(options){var name,path,_ref;if(this.templates){_ref=this.templates;for(name in _ref){if(!__hasProp.call(_ref,name))continue;path=_ref[name];this.templates[name]=this.fetchTemplate(path);}}
View.__super__.constructor.call(this,options);}
View.prototype._configure=function(options){View.__super__._configure.call(this,options);if(this.options.parent){this.parent=this.options.parent;}
if(this.options.params){this.params=this.options.params;}
if(this.options.app){this.app=this.options.app;}
if(!this.id){this.id=this.cid;}
if(!this.className){return this.className="ewok-view";}};View.prototype.setElement=function(element,delegate){View.__super__.setElement.call(this,element,delegate);this.$el.data('view',this);return this;};View.prototype.attach=function(target,events){var callback,event;this._attached||(this._attached=[]);for(event in events){if(!__hasProp.call(events,event))continue;callback=events[event];target.on(event,callback);this._attached.push({target:target,event:event,callback:callback});}
return this;};View.prototype.detach=function(){var item,_i,_len,_ref;if(this._attached){_ref=this._attached;for(_i=0,_len=_ref.length;_i<_len;_i++){item=_ref[_i];item.target.off(item.event,item.callback);}}
this._attached=[];return this;};View.prototype.addView=function(view,atts){if(atts==null){atts={};}
this._views||(this._views=[]);if(_.isFunction(view)){view=new view(atts);}
view.parent=this;this._views.push(view);view.render(this);return view;};View.prototype.close=function(){var view,_i,_len,_ref;this.unbind();this.detach();if(this._views){_ref=this._views;for(_i=0,_len=_ref.length;_i<_len;_i++){view=_ref[_i];view.close();}}
this.$el.data('view',null);this.remove();if(this.onClose){this.onClose();}
return this;};View.prototype.log=function(){var args,logPrefix;args=1<=arguments.length?__slice.call(arguments,0):[];logPrefix=this.constructor.name?"["+this.constructor.name+"]":'[View]';Ewok.loggable(this,logPrefix);return this['log'].apply(this,args);};View.prototype.show=function(){if(this.onShow){this.onShow();}
return this;};View.prototype.render=function(){var data;if(this.templates.main){data=this.model!=null?this.model.toJSON?this.model.toJSON():this.model:this.params?this.params:this.collection?{items:this.collection.toJSON()}:{};return this.$el.html(this.templates.main.render(data));}};View.prototype.fetchTemplate=function(path){if(_.isString(path)){return Ewok.fetchTemplate(path);}else{return path;}};return View;})(Backbone.View);Ewok.exports({View:View});$.fn.view=function(){var parent,view;view=null;parent=$(this);while(!view&&parent.length>0){view=parent.data('view');if(!view){parent=parent.parent();}}
return view;};}).call(this);(function(){var Model,__hasProp={}.hasOwnProperty,__extends=function(child,parent){for(var key in parent){if(__hasProp.call(parent,key))child[key]=parent[key];}function ctor(){this.constructor=child;}ctor.prototype=parent.prototype;child.prototype=new ctor();child.__super__=parent.prototype;return child;};Model=(function(_super){__extends(Model,_super);function Model(){return Model.__super__.constructor.apply(this,arguments);}
return Model;})(Backbone.Model);Ewok.exports({Model:Model});}).call(this);(function(){var Collection,__hasProp={}.hasOwnProperty,__extends=function(child,parent){for(var key in parent){if(__hasProp.call(parent,key))child[key]=parent[key];}function ctor(){this.constructor=child;}ctor.prototype=parent.prototype;child.prototype=new ctor();child.__super__=parent.prototype;return child;};Collection=(function(_super){__extends(Collection,_super);function Collection(){return Collection.__super__.constructor.apply(this,arguments);}
return Collection;})(Backbone.Collection);Ewok.exports({Collection:Collection});}).call(this);;