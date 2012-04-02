
ll = console.log
err = (str) -> throw new Error str

mask = '\u0000'

mask_blank = (str) ->
  in_quote = no
  now_quote = null
  for item, index in str
    if item is ' '
      unless in_quote
        str = str[...index] + mask + str[index+1..]
    else if item is '\''
      if now_quote in ['\'', null]
        if str[index-1]?
          if str[index-1] isnt '\\'
            if in_quote
              in_quote = off
              now_quote = null
            else
              in_quote = on
              now_quote = '\''
    else if item is '"'
      if now_quote in ['"', null]
        if str[index-1]?
          if str[index-1] isnt '\\'
            if in_quote
              in_quote = off
              now_quote = null
            else
              in_quote = on
              now_quote = '"'
  str


input_string = '(rever (list 1 \'d \' \'  d\' 3 false 4))'

parse = (arr) ->
  do recurse = ->
    head = do arr.shift
    if head is '('
      in_brackets = []
      in_brackets.push do recurse until arr[0] is ')'
      do arr.shift
      return in_brackets
    else head

make_arr = (str) ->
  str.replace(/([\(\)])/g, "#{mask}$1#{mask}")
      .split(mask)
      .filter (item) ->
        if item is '' then false else true

ll parse make_arr (mask_blank input_string)