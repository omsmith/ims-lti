crypto    = require 'crypto'
url       = require 'url'
utils     = require './utils'


# Cleaning invloves:
#   stripping the oauth_signature from the params
#   encoding the values ( yes this double encodes them )
#   sorting the key/value pairs
#   joining them with &
#   encoding them again
#
# Returns a string representing the request
_clean_request_body = (body, query) ->

  out = []

  encodeParam = (key, val) ->
    return "#{key}=#{utils.special_encode(val)}"

  cleanParams = (params) ->
    return if typeof params isnt 'object'

    for key, vals of params
      continue if key is 'oauth_signature'
      if Array.isArray(vals) is true
        for val in vals
          out.push encodeParam key, val
      else
        out.push encodeParam key, vals

    return

  cleanParams body
  cleanParams query

  utils.special_encode out.sort().join('&')



class HMAC_SHA1

  toString: () ->
    'HMAC_SHA1'

  build_signature_raw: (req_url, parsed_url, method, params, consumer_secret, token) ->
    sig = [
      method.toUpperCase()
      utils.special_encode req_url
      _clean_request_body params, parsed_url.query
    ]

    @sign_string sig.join('&'), consumer_secret, token

  build_signature: (req, body, consumer_secret, token) ->
    hapiRawReq = req.raw and req.raw.req
    if hapiRawReq
      req = hapiRawReq

    originalUrl = req.originalUrl or req.url
    protocol = req.headers['x-forwarded-proto'] or req.protocol

    # Since canvas includes query parameters in the body we can omit the query string
    if body.tool_consumer_info_product_family_code == 'canvas'
      originalUrl = url.parse(originalUrl).pathname

    if protocol is undefined
      encrypted = req.connection.encrypted
      protocol = (encrypted and 'https') or 'http'
    
    parsedUrl  = url.parse originalUrl, true
    hitUrl     = protocol + '://' + req.headers.host + parsedUrl.pathname

    @build_signature_raw hitUrl, parsedUrl, req.method, body, consumer_secret, token

  sign_string: (str, key, token) ->
    key = "#{key}&"
    key += token if token

    crypto.createHmac('sha1', key).update(str).digest('base64')

exports = module.exports = HMAC_SHA1
