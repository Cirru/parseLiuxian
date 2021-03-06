
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
    throw new Error "pathesis not match, defa"

fs = require 'fs'
input_data = fs.readFileSync 'code.lx', 'utf-8'

input_array = input_data.split '\n'
code_lines = []
codeline = yes
for item in input_array
  image = item.match /^\s*\#\#\#/
  if image?
    codeline = if codeline then no else yes
  else if codeline
    code_lines.push item

pure_codelines = []
for line in code_lines
  image = line.match /^\s{2,}\S+/
  if image?
    pure_codelines.push line[2..]

fold_input_array = []
for line, index in pure_codelines
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
  
  if dn >= 0
    count_left = 0
    count_right = 0
    for item in line
      if item is '(' then count_left += 1
      if item is ')' then count_right += 1
    ndn = count_left - count_right
    while ndn > 0
      src_arr[index] += ')'
      ndn -= 1

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
# ll source_array

sequence = (arr) ->
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
    when 'obj'   then exp = make_object     body
    when 'arr'   then exp = make_array      body
    when 'var'   then exp = declare_varable body
    when 'let'   then exp = assign_varable  body
    when 'for'   then exp = for_loop        body
    when 'cut'   then exp = cut_array_str   body
    when 'new'   then exp = new_object      body
    when 'fn'    then exp = define_function body
    when 'if'    then exp = if_expression   body
    when 'while' then exp = while_loop      body
    when 'chain' then exp = cascading       body
    when 'fetch' then exp = fetch_package   body
    else
      if head in ['+', '-', '*', '/', '%', '<', '>']
        exp =  calculate head, body
      else if (image = head.match /^\/.+/)
        exp = run_method head, body
      else if (image = head.match f_available)?
        exp = run_function head, body
  exp

exp_judge = (x) ->
  if typeof x is 'string'
    if x.match f_available
      return va x
    else
      return x
  if typeof x is 'object'
    return expend x
  throw new Error 'wrong type for calculate'

calculate = (head, body) ->
  exp = (body.map exp_judge).join head
  "#{exp}"

f_available = /^[\w\!\?@#\$\%\^\&\*\-\=\+:\/]+/
run_function = (head, body) ->
  body = body.map exp_judge
  head = va head
  "#{head}(#{body})"

declare_varable = (arr) ->
  varable = va arr[0]
  value = arr[1]
  if typeof varable is 'string'
    value = exp_judge value
    return "var #{varable} = #{value}"
  else throw new Error 'wrong type in declare'

assign_varable = (arr) ->
  varable = va arr[0]
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
      index = va item[0]
      value = exp_judge item[1]
      exp.push "#{index}: #{value}"
    else throw new Error 'err in making obj'
  "{#{exp.join ', '}}"

define_function = (arr) ->
  func = arr[0]
  args = ''
  if typeof func is 'object'
    args = func[1..].join ', '
    func = va func[0]
  body = sequence arr[1..]
  "function #{func}(#{args}){#{body}}"

if_expression = (arr) ->
  exp = []
  els = ''
  for item in arr
    if typeof item[0] is 'object'
      cond = expend item[0]
      body = sequence item[1..]
      exp.push "if(#{cond}){#{body}}"
    else
      els = sequence item[1..]
  (exp.join 'else ') + "else{#{els}}"

while_loop = (arr) ->
  cond = expend arr[0]
  body = sequence arr[1..]
  "while(#{cond}){#{body}}"

for_loop = (arr) ->
  range = exp_judge arr[0]
  varas = arr[1]
  if typeof varas is 'object'
    value = varas[0]
    key = varas[1]
  else
    value = varas
    key = undefined
  body = sequence arr[2..]
  exp = "for(var _i in #{range}){"
  exp += "#{value} = #{range}[_i];"
  if key?
    exp += "#{key} = _i;"
  else
    exp += 'delete _i;'
  exp += "#{body}}"

va_list =
  '!': '1'
  '?': '2'
  '@': '3'
  '#': '4'
  '_': '5'
  '%': '6'
  '^': '7'
  '&': '8'
  '*': '9'
  '-': '0'
  '=': 'a'
  '+': 'b'
  ':': 'c'
va_map = (str) ->
  new_str = ''
  for item in str
    if va_list[item]?
      new_str += '_' + va_list[item]
    else
      new_str += item
  new_str
va = (str) ->
  available = /^([\w\!\?@#\$\%\^\&\*\-\=\+:]*)(.*)/
  image = str.match available
  exp = va_map image[1]
  left = image[2]
  while left.length > 0
    if left[0] is '/'
      image = left[1..].match available
      sub_exp = va_map image[1]
      left = image[2]
      exp += "['#{sub_exp}']"
      continue
    throw new Error "varable cant be recognized"
  exp

cascading = (arr) ->
  name = arr[0]
  args = arr[1..]
  exp = name
  for item in args
    method = item[0]
    sub_args = (item[1..].map exp_judge).join ', '
    exp += ".#{method}(#{sub_args})"
  exp

run_method = (head, body) ->
  head = va head
  obj = exp_judge body[0]
  args = body[1..].map exp_judge
  "#{obj}#{head}(#{args})"

cut_array_str = (arr) ->
  data = exp_judge arr[0]
  start = arr[1]
  end = if arr[2]? then ', '+arr[2] else undefined
  exp = "#{data}.slice(#{start}#{end})"

new_object = (arr) ->
  head = arr[0]
  args = arr[1..].map exp_judge
  "new #{head}(#{args})"

fetch_package = (arr) ->
  head = arr[0]
  fetch_url = arr[1]
  body = sequence arr[2..]
  exp = """
    url = #{fetch_url};
    if((typeof exports)!='undefined'){
      http = require('http');
      image = url.match(/^(http(s)?:(\\\/\\\/)?)?([^\/]+)(\\\/.+)$/);
      if ((typeof image)!='undefined'){
        var options = {};
        options.host = image[4];
        options.path = image[5];
        var handler = function (res){
          var data = '';
          res.on('data', function(piece){
            data += piece;
            });
          res.on('end', function(){
            var liuxian = {};
            eval(data);
            var #{head} = liuxian;
            #{body}
            });
        }
        var http = require('http');
        http.request(options, handler).end();
      }
    }
    if ((typeof window)!='undefined'){
      // cross-domain http request hard for me...
    }
  """

target = sequence source_array

beautify = (require './beautify').js_beautify
fs.writeFile 'target.js', (beautify target), 'utf-8'