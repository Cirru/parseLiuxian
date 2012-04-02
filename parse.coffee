
ll = console.log
err = (str) -> throw new Error str

mask = '\u0000'
mask_left = '\u0001'
mask_right = '\u0002'
mask_3 = '\u0003'

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
    else if item is '('
      if in_quote
        str = str[...index] + mask_left + str[index+1..]
    else if item is ')'
      if in_quote
        str = str[...index] + mask_right + str[index+1..]
    else if item is '\\'
      if in_quote
        str = str[...index] + mask_3 + str[index+1..]

  count_left = 0
  count_right = 0
  for item in str
    count_left += 1 if item is '('
    count_right += 1 if item is ')'
  if count_right is count_left
    return str
  else
    throw new Error "pathesis not match"

fs = require 'fs'
input_data = fs.readFileSync 'code.lx', 'utf-8'

input_array = []
for line in input_data.split '\n'
  image = line.match /^\s{2,}/
  if image?
    input_array.push line[2..]
ll input_array

fold_input_array = []
for line, index in input_array
  image = line.match /^\s*\\(.+)/
  if image?
    if fold_input_array[index-1]?
      fold_input_array[index-1] += image[1]
  else
    fold_input_array.push line

src_arr = fold_input_array
get_indents = (item) ->
  image = item.match /^(\s*)/
  image[1].length
for line, index in src_arr
  line = line.replace /\s\\\s/g, ' ( '
  src_arr[index] = '(' + line
  curr_indent = get_indents line
  next_indent = 0
  if src_arr[index+1]?
    next_indent = get_indents src_arr[index+1]
  dn = (curr_indent - next_indent) / 2
  if dn isnt (Math.round dn)
    throw new Error 'bad indentation'
  while dn >= 0
    src_arr[index] += ')'
    dn -= 1

input_string = '(' + (src_arr.join '') + ')'
ll input_string

parse = (arr) ->
  do recurse = ->
    head = do arr.shift
    if head is '('
      in_brackets = []
      in_brackets.push do recurse until arr[0] is ')'
      do arr.shift
      return in_brackets
    else
      return head.replace(/\u0001/g, '(')
        .replace(/\u0002/g, ')')
        .replace(/\u0003/g, '\\')

make_arr = (str) ->
  str.replace(/([\(\)])/g, "#{mask}$1#{mask}")
      .split(mask)
      .filter (item) ->
        if item is '' then false else true

source_array = parse make_arr (mask_blank input_string)

ll source_array[1]
sequential_excution = (arr) ->
  return 0