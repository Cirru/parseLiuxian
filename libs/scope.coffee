
ll = console.log

url_str = 'docview.cnodejs.net/learning/coffee/snippets/test_lib/libs.js?js'
parse_url = (str) ->
  image = str.match /^([^/]+)(\/.+)$/
  obj =
    host: image[1]
    path: image[2]

online_path = parse_url url_str

options =
  host: online_path.host
  path: online_path.path
  method: 'GET'

handler = (res) ->
  data = ''

  res.on 'data', (piece) ->
    data += piece
  res.on 'end', ->
    liuxian = {}
    eval data
    ll liuxian

http = require 'http'
(http.request options, handler).end()