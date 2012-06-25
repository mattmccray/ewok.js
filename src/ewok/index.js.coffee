###
  Ewok v0.4
  YUB NUB!
###

#= require_self
#= require ewok/app
#= require ewok/view
#= require ewok/model
#= require ewok/collection

@Ewok=

  VERSION: "0.4"

  exports: (methods)->
    _.extend @, methods
    @

  eventable: (obj)->
    _.extend obj, Backbone.Events
    obj.fire= obj.trigger
    @

  loggable: (obj, prefix="")->
    _.extend obj, logger(prefix)
    @
  
  deferLoggable: (obj, prefix="")->
    _.extend obj, log: (args...)->
      logPrefix= if @.constructor.name then "[#{@.constructor.name}]" else prefix
      Ewok.loggable( @, logPrefix)
      @['log'].apply(@, args)
    @


  fetchTemplate: ((has_blam, has_hogan)->
    if has_blam
      (idOrTmpl)->
        blam.compile getTemplateContent(idOrTmpl)
    else if has_hogan
      (idOrTmpl)-> 
        Hogan.compile getTemplateContent(idOrTmpl)
    else
      (idOrTmpl)-> 
        _.template getTemplateContent(idOrTmpl)
  )(blam?, Hogan?)


# HELPERS

has_console= if window.console and console.log then yes else no
can_apply_log= 
  try
    console.log.apply console, ["[Ewok] waking up..."]
    true
  catch ex
    console.log "NOPE!", ex
    false


logger= (prefix)->
  con={}
  con.log= if has_console
    if can_apply_log
      (args...)->
        args.unshift prefix
        console.log.apply console, args
    else
      (args...)-> # For IE, I guess?
        console.log prefix
        for arg in args
          console.log arg
  else
    -> # NOOP
  # TODO: Add .info .warn .error
  con

getTemplateContent= (path)->
  if _.isString(path)
    if path.charAt(0) is "#" then $(path).text() else path
  else if _.isFunction(path)
    path


Ewok.loggable Ewok
Ewok.eventable Ewok
