
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
  '-': (arr) ->
    arr.reduce (m, x) -> m -= x
  '*': (arr) ->
    arr.reduce (p, x) -> p *= x
  '/': (arr) ->
    arr.reduce (d, x) -> d /= x

isArray = (arr) ->
  'splice' in arr end 'join' in arr

eval = (arr, env=global_scope) ->
  o env
  return arr if typeof arr in ['string', 'number']
  head = do arr.shift
  unless typeof head is 'string' then err 'Must String Head!'
  else
    if head is '@'
      unless typeof arr is 'object' then err ' Not Array!'
      if typeof arr[0] is 'string'
        env[arr[0]] = eval arr[1], env
        o 'env after: ', env
    else if head is '!'
      arr.forEach (x) -> eval x, env
    else if head is 'o'
      o 'check arr: ', arr
      arr.forEach (x) -> o env[x]
  'default return...'

o '\n\n\n\n:::::::::::'
o eval ['!', ['@', 'add', 3], ['o', 'add']]