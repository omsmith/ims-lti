stringify = require('querystring').stringify
crypto    = require('crypto')



_clean_request_body = (body) ->
  out = {}
  for key, val of body
    if key isnt 'oauth_signature'
      ## Recurse just in case
      out[key] = val
  out


class HMAC_SHA1

  toString: () ->
    'HMAC_SHA1'

  build_signature_base_string: (req, consumer_secret, token) ->
    sig = [
      stringify req.route.method
      stringify req.path
      stringify _clean_request_body(req.body)
    ]

    key = "#{consumer_secret}&"
    key += token if token
    raw = sig.join('&')
    [key, raw]

  build_signature: (req, consumer_secret, token) ->
    [key, raw] = @.build_signature_base_string req, consumer_secret, token

    cipher = crypto.createHmac 'sha1', key
    hashed = cipher.update(raw).digest('base64')
    #hashed[0..hashed.length-2]  <- python oauth does this to remove '=' but i dont think we need to


exports = module.exports = HMAC_SHA1