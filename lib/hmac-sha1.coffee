stringify = require('querystring').stringify
crypto    = require('crypto')



special_encode = (string) ->
  encodeURIComponent(string).replace(/'/g,"%27").replace(/\!/g, "%21")

_clean_request_body = (body) ->
  out = []
  return body if typeof body isnt 'object'
  for key, val of body
    continue if key is 'oauth_signature'
    out.push "#{key}=#{special_encode(val)}"

  special_encode out.sort().join('&')



class HMAC_SHA1

  toString: () ->
    'HMAC_SHA1'

  build_signature_base_string: (req, consumer_secret, token) ->

    hitUrl = req.protocol + "://" + req.get('host') + req.url

    sig = [
      req.route.method.toUpperCase()
      special_encode hitUrl
      _clean_request_body req.body
    ]

    key = "#{consumer_secret}&"
    key += token if token

    raw = sig.join '&'
    [key, raw]

  build_signature: (req, consumer_secret, token) ->
    [key, raw] = @.build_signature_base_string req, consumer_secret, token

    cipher = crypto.createHmac 'sha1', key
    hashed = cipher.update(raw).digest('base64')
    #hashed[0..hashed.length-2]  <- python oauth does this to remove '=' but i dont think we need to


exports = module.exports = HMAC_SHA1