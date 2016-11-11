crypto            = require 'crypto'
URL         = require 'url-parse'
HMAC_SHA1         = require './hmac-sha1'
errors            = require './errors'
extensions        = require './extensions'

class Consumer
  constructor: (consumer_key, consumer_secret) ->
    if typeof consumer_key is 'undefined' or consumer_key is null
      throw new errors.ConsumerError 'Must specify consumer_key'

    if typeof consumer_secret is 'undefined' or consumer_secret is null
      throw new errors.ConsumerError 'Must specify consumer_secret'

    @consumer_key     = consumer_key
    @consumer_secret  = consumer_secret
    @signer           = new HMAC_SHA1()
    @body             = {}

  sign_request: (url, method = 'GET', body = {}) =>
    if typeof url is 'undefined' or (not url?.length)
      throw new errors.ConsumerError 'Must specify a non empty URL'

    if typeof method is 'undefined' or method is null
      throw new errors.ConsumerError 'Must specify a method'

    if typeof body isnt 'object' or body is null
      throw new errors.ConsumerError 'Must specify body as an object'

    body.oauth_nonce = crypto.randomBytes(Math.ceil(16)).toString('hex').slice(0, 32)
    body.oauth_consumer_key = @consumer_key
    body.oauth_signature_method = 'HMAC-SHA1'
    body.oauth_timestamp = Math.floor(new Date() / 1000)
    body.oauth_version = '1.0'
    body.oauth_callback = 'about:blank'

    urlObject = new URL(url)
    parsedUrl = {
      url: url,
      protocol: urlObject.protocol.slice(0, -1),
      headers: {
        host: urlObject.host,
      },
      method: method,
    };

    sig = @signer.build_signature parsedUrl, body, @consumer_secret
    body.oauth_signature = sig

    return body

exports = module.exports = Consumer
