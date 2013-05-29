HMAC_SHA1         = require './hmac-sha1'
MemoryNonceStore  = require './memory-nonce-store'



class Provider

  constructor: (consumer_key, consumer_secret, signature_method=(new HMAC_SHA1()), nonceStore ) ->

    if typeof consumer_key is 'undefined' or consumer_key is null
      throw new Error 'Must specify consumer_key'

    if typeof consumer_secret is 'undefined' or consumer_secret is null
      throw new Error 'Must specify consumer_secret'

    if not nonceStore
      nonceStore = new MemoryNonceStore(consumer_key)

    if not nonceStore.isNonceStore?()
      throw new Error 'Fourth argument must be a nonceStore object'

    @consumer_key     = consumer_key
    @consumer_secret  = consumer_secret
    @signer           = signature_method
    @nonceStore       = nonceStore


  # Verify parameter and OAuth signature by passing the request object
  # Returns true/false if is valid
  #
  # Sets up request variables for easier access down the line
  valid_request: (req=@req) ->
    @req = req if not @req
    @parse_request(req)
    @_valid_parameters(req) and @_valid_oauth(req)


  # Helper to validate basic LTI parameters
  #
  # Returns true/false if is valid LTI request
  _valid_parameters: (req) ->
    corrent_message_type = req.body.lti_message_type is 'basic-lti-launch-request'
    correct_version      = require('./ims-lti').supported_versions.indexOf(req.body.lti_version) isnt -1
    has_resource_link_id = req.body.resource_link_id?
    corrent_message_type and correct_version and has_resource_link_id


  # Helper to validate the OAuth information in the request
  #
  # Returns true/false if is valid OAuth signatue and nonce
  _valid_oauth: (req) =>
    generated = @signer.build_signature req, @consumer_secret
    generated is req.body.oauth_signature and @nonceStore.isNew(req.body.oauth_nonce, req.body.oauth_timestamp)





  parse_request: (req=@req) ->
    @_body = {}
    for key, val in req.body
      continue if key.match(/oauth/)
      @_body[key] = val










exports = module.exports = Provider
