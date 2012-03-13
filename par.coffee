
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
    seek: (varb) =>
      if @[varb]? then @ else env.seek varb
global_scope =
  seek: (varb) ->
    if @[varb]? then @ else undefined
  '+': (arr) ->
    arr.reduce (s, x) -> s += x
  '>': (arr) ->
    o 'in >: ', arr
    for x, i in arr[1..]
      if x>=arr[i] then return false
    return true

isArray = (arr) ->
  'splice' in arr end 'join' in arr

eval = (arr, env=global_scope) ->
  o env, arr
  return arr if typeof arr in ['string', 'number']
  head = do arr.shift
  unless typeof head is 'string' then err 'Must String Head!'
  else
    if head is '@'
      unless typeof arr is 'object' then err ' Not Array!'
      if typeof arr[0] is 'string'
        seek = env.seek arr[0]
        arr[1] = eval arr[1], env
        o 'arr[1]: ', arr[1]
        if seek? then seek[arr[0]] = arr[1]
        else env[arr[0]] = eval arr[1], env
        o 'env[arr[0]]', env[arr[0]]
        return env[arr[0]]
      else
    else if head is '!'
      arr.forEach (x) -> eval x, env
      o env
      return 'done (!)'
    else if head is 'o'
      o 'check arr: ', arr[0]
      arr.forEach (x) -> o env[x]
      o arr.join ', '
      return 'done::o'
    else if head is 'if'
      o 'check in if: ', arr
      arr[0] = eval arr[0], env
      if arr[0] is true then eval arr[1], env
      else eval arr[2], env
      return 'done if...'
    else
      seek = env.seek head
      o 'seek is: ', seek
      arr = arr.map (x) -> eval x, env
      o 'after seeking: ', arr
      if seek? then return seek[head] arr
      else err 'found no function'
  'default return...'

o '\n\n:::::::::::'
# o eval ['!', ['@', 'add', ['+', 1, ['@', 'add2', 4]]], ['o', 'add'], ['o', 'add2']]
o eval ['if', ['>', ['+', 1, 2], 1], ['o', 'true'], ['o', 'false']]