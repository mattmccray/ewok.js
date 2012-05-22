
class Template
  @compile: (source)->
    template= new @(source)
    template.compile()

  constructor: (@source)->

  parse: ->
    try
      balanced=0
      @src= $.trim(@source)
      code= ['list']
      while @src.length
        code= code.concat @parser()
      if balanced > 0
        throw "The expression is not balanced. Add #{balanced} parentheses."
      else if balanced < 0
        throw "The expression is not balanced. Remove #{Math.abs balanced} parentheses."
      @env or= {}
      @eval().pop()
    catch ex
      @log "Error: #{ex}"

  parser: ->

  eval: ->

  compile: ->
    @

  render: (data, helpers={})->
    ""

Ewok
  .loggable( Template::, "[Template]")
  .exports { Template }

helpers=
  print: ->
    s= ""
    s += str for str in arguments
    #Ewok.log "print called", arguments
    Ewok.log s
    ""

operators=
  # lisp-y list-y stuff
  first: ->
    l= arguments[0]
    return null if !l or !l.length
    l[0]
  rest: ->
    l= arguments[0]
    return [] if !l or !l.length
    l.slice(1)
  cons: ->
    a= arguments[1]
    return [arguments[0]] unless a
    a.unshift arguments[0]
    a
  # Logical
  not: ->
    !arguments[0]
  and: ->
    for arg in arguments
      return false if !arg
    true
  or: ->
    for arg in arguments
      return true if arg
    false
  # Comparison
  "<=": (x,y)-> x <= y
  "<": (x,y)-> x < y
  ">=": (x,y)-> x >= y
  ">": (x,y)-> x > y
  "=": (x,y)-> x == y
  "eq": (x,y)-> x == y
  "neq": (x,y)-> x != y
  # Arithmetic
  "+": ->
    # supports numbers or strings (acts as concat)
    res= if isNaN(arguments[0]) then "" else 0
    $.each arguments, (i,x)-> res += x
    res
  "-": ->
    res= arguments[0] * 2
    $.each arguments, (i,x)-> res -= x
    res
  "*": ->
    res= 1
    $.each arguments, (i,x)-> res *= x
    res
  "/": ->
    res= arguments[0] * arguments[0]
    $.each arguments, (i,x)-> res /= x
    res
  # TODO: let
  
operators.car=operators.first
operators.cdr=operators.rest

# make_tag= (expr)->
#   tag= expr[0]
#   Ewok.log "MAKE TAG:", tag, expr
#   body= ""
#   $.each arguments, (i,x)-> body+=x
#   "<#{tag}>#{body}</#{tag}>"

# TODO: Support #{} within strings


attrRE= /([\w]*)="([\w ]*)"/

parseAttrs= (val)->
  if typeof(val) is 'string' and attrRE.test(val)
    # Ewok.log("matches", val.match(attrRE))
    [full,key,value]= val.match(attrRE)
    " #{key}=\"#{value}\""
  else
    false


tag_builder= (expr, evaluate)->
    body= ""
    attrs= ""
    tag= expr[0]
    if (parts= tag.split('.')).length > 1
      tag= parts.shift()
      attrs += " class=\"#{parts.join(' ')}\""
    for exp in expr[1...]
      if attr= parseAttrs(exp)
        attrs += attr
      else
        body += evaluate exp
    "<#{tag}#{attrs}>#{body}</#{tag}>"

tags= {}

for tagName in "a abbr address area article aside audio b base bdi bdo blockquote body br button canvas caption cite code col colgroup command data datalist dd del details dfn div dl dt em embed eventsource fieldset figcaption figure footer form h1 h2 h3 h4 h5 h6 head header hgroup hr html i iframe img input ins kbd keygen label legend li link mark map menu meta meter nav noscript object ol optgroup option output p param pre progress q ruby rp rt s samp script section select small source span strong style sub summary sup table tbody td textarea tfoot th thead time title tr track u ul var video wbr".split(' ')
  tags[tagName]= tag_builder #tag_handler(tagName)


Ewok.sexp= (src, extras={})->
  _text= $.trim(src)
  _balanced= 0
  _env= {}

  method_missing= (expr)->
    throw "#{expr} is not defined."

  method_missing= extras.method_missing if extras.method_missing

  scanner= ->
    # Ewok.log ":scanner", _text, _env
    return "" if _text.length is 0
    start= 0
    index= 1
    delta= 0
    fc= _text.charAt(0)
    if fc is '(' or fc is ')'
      index= 1
      _balanced += if fc is '(' then 1 else -1
    else if fc is '"'
      index= _text.search(/[^\\]"/) + 1
      delta=1 # bizarre bugfix... need to investigate further
    # else if fc is ':'
    #   index= _text.search(/[ \n)]/)
    else
      index= _text.search(/[ \n)]/)
    index= _text.length if index < 1
    t= _text.substring start, index
    _text= $.trim _text.substring(index + delta)
    # Ewok.log ":scanner", t, "_text:", _text
    t
  
  parser= ->
    result= []
    token= scanner()
    while token isnt ')' and token isnt ""
      expr= if token is '(' then parser() else token
      result.push expr
      token= scanner()
    result

  get_env= (expr,env)->
    return false if typeof(expr) isnt "string"
    return env[expr] if expr of env
    if (parts= expr.split('.')).length > 1
      if parts[0] of env
        obj=env
        for part in parts
          obj= obj[part] #if obj[part]
        return obj if obj != env
    return get_env(expr, env['_parent']) if '_parent' of env
    false

  apply_to= (proc, args)->
    return proc.apply(@, args) if $.isFunction proc
    throw "Procedure #{proc} is not defined"

  make_proc= (args, body, env)->
    (params...)->
      newenv= {}
      newenv['_parent']= env
      $.each args, (i,x)-> newenv[x]= params[i]
      $.each body.slice(0, body.length-1), (i,x)-> evaluate(x, newenv)
      evaluate body[body.length-1], newenv

  evaluate= (expr, env)->
    # Ewok.log ":evaluate", expr, env
    ez= expr[0]
    # Atoms
    return Number expr if not isNaN expr
    return null if expr is "nil" or expr is "null"
    if ez  is '"'
      v= expr.slice(1) 
      return v.replace(/[\\]"/g, '"')
    # return expr if ez  is ':' #?
    # List
    return $.map(expr.slice(1), (x)->
      v= evaluate x, env
      return Array v if $.isArray(v)
      v
    ) if ez is "list"
    if ez is 'quote' # not sure if this is really right or not...
      v=expr[1]
      return v.slice(1).replace(/[\\]"/g, '"') if v[0] is '"' # Just to pull out our string ident
      return v
    # Variables
    return ge if (ge= get_env(expr,env))
    if ez is "set" or ez is "set!" or ez is "setq"
      variable= env[expr[1]]= evaluate(expr[2], env)
      return variable
    # Conditional
    if ez is 'if'
      return evaluate expr[2], env if evaluate expr[1], env
      return null if expr.length <= 3
      $.each(expr.slice(2, expr[expr.length - 2]), (i,x)->
        evaluate x, env
      )
      return evaluate expr[expr.length - 1], env
    if ez is 'cond'
      cases= expr.slice(1, expr.length)
      for rule in cases
        return evaluate(rule[rule.length - 1]) if evaluate rule[0], env
      return null # since there's no cond match?
    if ez is 'each'
      # [target,keyword,source]=expr[1]
      source= expr[1][0]
      res=[]
      for data in evaluate(source, env)
        newenv= data
        newenv['_parent']= env
        res.push evaluate(expr[2], newenv)
        # delete newenv['_parent']
      return res.join('')

    # Procedures
    return operators[expr] if expr of operators
    if ez of tags
      ev= (src)-> evaluate src, env
      return tags[ez](expr, ev)
    else if typeof(ez) is 'string' and (parts= ez.split('.')).length > 1
      if parts[0] of tags
        ev= (src)-> evaluate src, env
        return tags[parts[0]](expr, ev)
    return helpers[expr] if expr of helpers
    return extras[expr] if expr of extras
    return make_proc expr[1], expr.slice(2), env if ez is 'lambda'
    return env[expr[1]]= make_proc expr[2], expr.slice(3), env if ez is 'defun'
    return eval(expr[1]) if ez is 'js'
    # Apply
    # return make_tag(expr, env)
    if $.isArray expr
      return apply_to(
        evaluate(ez, env),
        $.map(expr.slice(1), (x,i)-> 
          v= evaluate x, env
          if $.isArray(v) then Array v else v
        )
      )
    
    return method_missing(expr)

  
  try
    code= ['list']
    while _text.length
      code = code.concat parser()
    if _balanced > 0
      throw "The expression is not balanced. Add #{_balanced} parentheses."
    else if _balanced < 0
      throw "The expression is not balanced. Remove #{Math.abs _balanced} parentheses."
    render=(env={})->
      # Ewok.log "Evaluating", code
      env._root= env
      evaluate(code, env).pop()
    render.code= code
    render.render= (env={})->
      try
        render(env)
      catch ex
        "Error: #{ex}"
    render
  catch ex
    (env={})->
      "Error: #{ex}"


