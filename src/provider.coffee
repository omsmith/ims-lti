HMAC_SHA1         = require './hmac-sha1'
MemoryNonceStore  = require './memory-nonce-store'
errors            = require './errors'
extensions        = require './extensions'



class Provider
  constructor: (consumer_key, consumer_secret, optionsOrNonceStore, signature_method) ->

    if typeof consumer_key is 'undefined' or consumer_key is null
      throw new errors.ConsumerError 'Must specify consumer_key'

    if typeof consumer_secret is 'undefined' or consumer_secret is null
      throw new errors.ConsumerError 'Must specify consumer_secret'

    if optionsOrNonceStore and optionsOrNonceStore.isNonceStore?()
      options = {}
      nonceStore = optionsOrNonceStore
    else
      options = optionsOrNonceStore or {}
      nonceStore = options.nonceStore or new MemoryNonceStore()

    if not signature_method
      signature_method = options.signer or new HMAC_SHA1(options)

    @consumer_key     = consumer_key
    @consumer_secret  = consumer_secret
    @signer           = signature_method
    @nonceStore       = nonceStore
    @body             = {}


  # Verify parameter and OAuth signature by passing the request object
  # Returns true/false if is valid
  #
  # Sets up request variables for easier access down the line
  valid_request: (req, body, callback) =>
    if not callback
      callback = body
      body = undefined

    body = body or req.body or req.payload
    callback = callback or () ->

    @parse_request(req, body)

    if not @_valid_parameters(body)
      return callback(new errors.ParameterError('Invalid LTI parameters'), false)

    @_valid_oauth req, body, callback


  # Helper to validate basic LTI parameters
  #
  # Returns true/false if is valid LTI request
  _valid_parameters: (body) ->
    if not body
      return false

    correct_version      = require('./ims-lti').supported_versions.indexOf(body.lti_version) isnt -1
    has_resource_link_id = body.resource_link_id?
    omits_content_item_params = 
      not body.resource_link_id? and
      not body.resource_link_title? and 
      not body.resource_link_description? and 
      not body.launch_presentation_return_url? and
      not body.lis_result_sourcedid?
    correct_version and
      ( body.lti_message_type is 'basic-lti-launch-request' and has_resource_link_id ) or
      ( body.lti_message_type is 'ContentItemSelectionRequest' and omits_content_item_params )

  # Helper to validate the OAuth information in the request
  #
  # Returns true/false if is valid OAuth signatue and nonce
  _valid_oauth: (req, body, callback) ->
    generated = @signer.build_signature req, body, @consumer_secret
    valid_signature = generated is body.oauth_signature
    return callback new errors.SignatureError('Invalid Signature'), false if not valid_signature
    @nonceStore.isNew body.oauth_nonce, body.oauth_timestamp, (err, valid) ->
      if not valid
        callback new errors.NonceError('Expired nonce'), false
      else
        callback null, true


  # Stores the request's properties into the @body accessor
  #  Strips 'oauth_' parameters for saftey
  #
  # Does not return anything
  parse_request: (req, body) =>
    body = body or req.body or req.payload

    for key, val of body
      continue if key.match(/^oauth_/)
      @body[key] = val

    @body.roles = @body.roles.split ',' if typeof @body.roles is 'string'

    @admin = @has_role('Administrator')
    @alumni = @has_role('Alumni')
    @content_developer = @has_role('ContentDeveloper')
    @guest = @has_role('Guest')
    @instructor = @has_role('Instructor') or @has_role('Faculty') or @has_role('Staff')
    @manager = @has_role('Manager')
    @member = @has_role('Member')
    @mentor = @has_role('Mentor')
    @none = @has_role('None')
    @observer = @has_role('Observer')
    @other = @has_role('Other')
    @prospective_student = @has_role('ProspectiveStudent')
    @student = @has_role('Learner') or @has_role('Student')
    @ta = @has_role('TeachingAssistant')

    @launch_request = @body.lti_message_type is 'basic-lti-launch-request'

    # user
    @username = @body.lis_person_name_given or @body.lis_person_name_family or @body.lis_person_name_full or ''
    @userId   = @body.user_id

    @mentor_user_ids = (decodeURIComponent(id) for id in @body.role_scope_mentor.split ',') if typeof @body.role_scope_mentor is 'string'

    # Context information
    @context_id     = @body.context_id
    @context_label  = @body.context_label
    @context_title  = @body.context_title

    # Load up the extensions!
    extension.init(@) for extension_name, extension of extensions


  # has_role Helper
  has_role: (role) ->
    # There's 3 different types of roles: system, institution, and context. Each one has their own unique identifier
    # string within the urn prefix. This regular expression can verify the prefix is there at all, and if it is, ensure
    # that it matches one of the three different ways that it can be formatted. Additionally, context roles can have a
    # suffix that futher describes what the role may be (such as an instructor that is a lecturer). Those details are
    # probably a bit too specific for most cases, so we can just verify that they are optionally there.
    regex = new RegExp "^(urn:lti:(sys|inst)?role:ims/lis/)?#{role}(/.+)?$", 'i'
    @body.roles && @body.roles.some (r) -> regex.test(r)



exports = module.exports = Provider
