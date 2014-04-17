crypto    = require('crypto')



# Special encode is our encoding method that implements
#  the encoding of characters not defaulted by encodeURI
#
#  Specifically ' and !
#
# Returns the encoded string
special_encode = (string) ->
  encodeURIComponent(string).replace(/[!'()]/g, escape).replace(/\*/g, '%2A')


# Cleaning invloves:
#   stripping the oauth_signature from the params
#   encoding the values ( yes this double encodes them )
#   sorting the key/value pairs
#   joining them with &
#   encoding them again
#
# Returns a string representing the request
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

    hitUrl = req.protocol + '://' + req.get('host') + req.url

    sig = [
      req.method.toUpperCase()
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


exports = module.exports = HMAC_SHA1
