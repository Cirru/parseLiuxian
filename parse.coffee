
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
ll source_array

sequential_excution = (arr) ->
  effort = ''
  for line in arr
    effort += (expend line) + ';'
  effort

expend = (arr) ->
  throw new Error 'empty exp..' if arr.length is 0
  head = arr[0]
  body = arr[1..]
  exp = 'Error if you can see..'
  switch head
    when 'obj' then exp = make_object     body
    when 'arr' then exp = make_array      body
    when 'var' then exp = declare_varable body
    when 'let' then exp = assign_varable  body
    when 'fn'  then exp = define_function body
    when 'if'  then exp = if_expression   body
    else
      if head in ['+', '-', '*', '/', '%', '<', '>']
        exp =  calculate head, body
      if (image = head.match /^((\w+\/)*\w+)$/)?
        exp = run_function head, body
  exp

exp_judge = (x) ->
  if typeof x is 'string'
    return x
  if typeof x is 'object'
    return expend x
  throw new Error 'wrong type for calculate'

calculate = (head, body) ->
  exp = (body.map exp_judge).join head
  "#{exp}"

run_function = (head, body) ->
  body = body.map exp_judge
  head = head.replace /\//g, '.'
  "#{head}(#{body})"

declare_varable = (arr) ->
  varable = arr[0]
  value = arr[1]
  if typeof varable is 'string'
    value = exp_judge value
    return "var #{varable} = #{value}"
  else throw new Error 'wrong type in declare'

assign_varable = (arr) ->
  varable = arr[0]
  value = arr[1]
  if typeof varable is 'string'
    value = exp_judge value
    return "#{varable} = #{value}"
  else throw new Error 'wrong type in assign'

make_array = (arr) ->
  arr = arr.map exp_judge
  exp = arr.join ', '
  "[#{exp}]"

make_object = (arr) ->
  exp = []
  for item in arr
    if typeof item[0] is 'string'
      index = item[0]
      value = exp_judge item[1]
      exp.push "#{index}: #{value}"
    else throw new Error 'err in making obj'
  "{#{exp.join ', '}}"

define_function = (arr) ->
  args = arr[0].join ', '
  body = sequential_excution arr[1..]
  "function(#{args}){#{body}}"

if_expression = (arr) ->
  exp = []
  els = ''
  for item in arr
    if typeof item[0] is 'object'
      cond = expend item[0]
      body = sequential_excution item[1..]
      exp.push "if(#{cond}){#{body}}"
    else
      els = sequential_excution item[1..]
  (exp.join 'else ') + "else{#{els}}"

target = sequential_excution source_array

beautify = (require './beautify').js_beautify
fs.writeFile 'target.js', (beautify target), 'utf-8'