
o = console.log
err = (str) -> throw new Error str

input_string = '(rever (list 1 3 4 4))'

parse = (arr) ->
  recurse = ->
    head = do arr.shift
    if head is '('
      in_brackets = []
      in_brackets.push do recurse until arr[0] is ')'
      do arr.shift
      in_brackets
    else
      x = Number head
      if x>0 or x<1 then x else head
  do recurse

make_arr = (str) ->
  str.replace(/([\(\)])/g, ' $1 ')
     .split(' ')
     .filter (item) ->
       if item is '' then false else true

# o parse make_arr input_string

scope = (env) ->
  obj =
    seek: (varb, envi) =>
      if envi[varb]? then envi else env.seek varb, env
global_scope =
  seek: (varb, envi) =>
    o 'refresh: ', @, envi, varb
    if envi[varb]? then envi else undefined
  '+': (arr) ->
    arr.reduce (s, x) -> s += x
  '>': (arr) ->
    for x, i in arr[1..]
      if x>=arr[i] then return false
    return true

isArray = (arr) ->
  'splice' in arr end 'join' in arr

eval = (arr, env=global_scope) ->
  o 'begin: ', arr, env
  return arr if typeof arr is'number'
  if typeof arr is 'string'
    seek = env.seek arr, env
    o arr, env, seek, env.seek
    if seek? then return seek[arr]
    else err 'not found string of var'
  head = do arr.shift
  unless typeof head is 'string' then err 'Must String Head!'
  else
    if head is '@'
      unless typeof arr is 'object' then err ' Not Array!'
      if typeof arr[0] is 'string'
        seek = env.seek arr[0], env
        arr[1] = eval arr[1], env
        if seek? then seek[arr[0]] = arr[1]
        else env[arr[0]] = eval arr[1], env
        return env[arr[0]]
      else
        o 'funcing', env
        seek = env.seek arr[0][0], env
        o 'still: ',arr
        func_scope = scope env
        func = (args) ->
          o 'in func', func_scope, arr, args
          for val, index in arr[0][1..]
            func_scope[val] = args[index]
          eval arr[1], func_scope
        if seek? then seek[arr[0][0]] = func
        else env[arr[0][0]] = func
        func
    else if head is '!'
      o 'at (!): ', arr
      arr.forEach (x) -> eval x, env
      return 'done (!)'
    else if head is 'o'
      arr = arr.map (x) -> eval x, env
      o arr.join ', '
      return 'done::o'
    else if head is 'if'
      arr[0] = eval arr[0], env
      if arr[0] is true then eval arr[1], env
      else eval arr[2], env
      return 'done if...'
    else
      o 'end: ', arr, env, head
      seek = env.seek head, env
      o 'so, here? '
      arr = arr.map (x) -> eval x, env
      if seek? then return seek[head] arr
      else err 'found no function'
  'default return...'

o '\n\n:::::::::::'
# o eval ['!', ['@', 'add', ['+', 1, ['@', 'add2', 4]]], ['o', 'add'], ['o', 'add2']]
# o eval ['if', ['>', ['+', 1, 2], 1], ['o', 'true'], ['o', 'false']]
# o eval ['!', ['@', 'b', 2], ['o', ['+', 1, 'b']]]
o eval ['!', ['@', ['a', 'b'], ['+', 1, 'b']], ['o', ['a', 2]]]
# o eval ['o', ['+', 1, 2]]