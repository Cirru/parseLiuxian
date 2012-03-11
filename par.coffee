
o = console.log

input_string = '(rever (list 1 3 4 4))'

parse = (arr) ->
  reverse = ->
    head = do arr.shift
    if head is '('
      in_brackets = []
      in_brackets.push do reverse until arr[0] is ')'
      do arr.shift
      in_brackets
    else
      x = Number head
      if x>0 or x<1 then x else head
  do reverse

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
    if @[varb]? then @ else throw new Error 'nowhere'
  '+': (arr) ->
    arr.reduce (x, s) -> s += x

eval = (arr, env=global_scope) ->
  head = do arr.shift
  action = typeof head
  if action is 'string'
    func = (env.seek head)[head]
    func arr.map (x) ->
      argv_type = typeof x
      switch argv_type
        when 'number' then x
        when 'string' then x
        else
          inside = scope env
          eval x, inside
  else if action is 'number' then head
  else
    inside = scope env
    eval arr, inside

o eval ['+', 1, ['+', ['+', 1, 3], ['+', ['+', 3, 4], 4]]]
o eval (parse (make_arr '(+ 2 (+ 3 (+ 3 44)))'))