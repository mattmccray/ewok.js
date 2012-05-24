###
  EWOK
    Elucidata Webapp 
###

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
  if path.charAt(0) is "#" then $(path).text() else path

@Ewok=

  VERSION: "0.2"

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

  # addFormatters: (hash)->
  #   kite.formatters[name]= fn for own name,fn of hash
  #   @

  fetchTemplate: ((has_settee, has_hogan)->
    if has_settee
      (idOrTmpl)->
        Settee getTemplateContent(idOrTmpl)
    else if has_hogan
      (idOrTmpl)-> 
        Hogan.compile getTemplateContent(idOrTmpl)
    else
      (idOrTmpl)-> 
        _.template getTemplateContent(idOrTmpl)
  )(Settee?, Hogan?)

Ewok.loggable Ewok
Ewok.eventable Ewok
