
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
  image = line.match /^\s{2,}\S+/
  if image?
    input_array.push line[2..]
# ll input_array

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
# ll input_string

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

sequential_excution = (arr) ->
  effort = ''
  for line in arr
    effort += (expend line)
  effort

expend = (arr) ->
  throw new Error 'empty exp..' if arr.length is 0
  s = arr[0]
  if s is 'var'
    return (declare_varable arr) + ';'
  if s is 'let'
    return (assign_varable arr) + ';'
  if s in ['+', '-', '*', '/', '%']
    return (calculate arr) + ';'
  if (image = s.match /^((\w+\/)*\w+)$/)?
    return (run_function arr) + ';'

exp_judge = (x) ->
  if typeof x is 'string'
    return x
  if typeof x is 'object'
    return expend x
  throw new Error 'wrong type for calculate'

calculate = (arr) ->
  new_arr = arr[1..].map exp_judge
  '(' + (new_arr.join arr[0]) + ')'

run_function = (arr) ->
  new_arr = arr[1..].map exp_judge
  func_name = arr[0].replace /\//g, '.'
  func_name + '(' + new_arr + ')'

declare_varable = (arr) ->
  varable = arr[1]
  value = arr[2]
  if typeof varable is 'string'
    if typeof value isnt 'string'
      value = expend value
    return "var #{varable} = #{value}"
  else throw new Error 'wrong type in declare'

assign_varable = (arr) ->
  varable = arr[1]
  value = arr[2]
  if typeof varable is 'string'
    if typeof value isnt 'string'
      value = expend value
    return "#{varable} = #{value}"
  else throw new Error 'wrong type in assign'

target = sequential_excution source_array

beautify = (require './beautify').js_beautify
fs.writeFile 'target.js', (beautify target), 'utf-8'