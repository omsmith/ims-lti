HMAC_SHA1         = require './hmac-sha1'
MemoryNonceStore  = require './memory-nonce-store'
OutcomeService    = require './outcome-service'
errors            = require './errors'



class Provider

  # Used as accessor to request parameters
  body: {}

  constructor: (consumer_key, consumer_secret, nonceStore, signature_method=(new HMAC_SHA1()) ) ->

    if typeof consumer_key is 'undefined' or consumer_key is null
      throw new errors.ConsumerError 'Must specify consumer_key'

    if typeof consumer_secret is 'undefined' or consumer_secret is null
      throw new errors.ConsumerError 'Must specify consumer_secret'

    if not nonceStore
      nonceStore = new MemoryNonceStore()

    if not nonceStore.isNonceStore?()
      throw new errors.ParameterError 'Fourth argument must be a nonceStore object'

    @consumer_key     = consumer_key
    @consumer_secret  = consumer_secret
    @signer           = signature_method
    @nonceStore       = nonceStore


  # Verify parameter and OAuth signature by passing the request object
  # Returns true/false if is valid
  #
  # Sets up request variables for easier access down the line
  valid_request: (req, callback=()->) =>
    @parse_request(req)
    if not @_valid_parameters(req)
      return callback(new errors.ParameterError('Invalid LTI parameters'), false)
    @_valid_oauth req, (err, valid) -> callback err, valid


  # Helper to validate basic LTI parameters
  #
  # Returns true/false if is valid LTI request
  _valid_parameters: (req) ->
    correct_message_type = req.body.lti_message_type is 'basic-lti-launch-request'
    correct_version      = require('./ims-lti').supported_versions.indexOf(req.body.lti_version) isnt -1
    has_resource_link_id = req.body.resource_link_id?
    correct_message_type and correct_version and has_resource_link_id


  # Helper to validate the OAuth information in the request
  #
  # Returns true/false if is valid OAuth signatue and nonce
  _valid_oauth: (req, callback) ->
    generated = @signer.build_signature req, @consumer_secret
    valid_signature = generated is req.body.oauth_signature
    return callback new errors.SignatureError('Invalid Signature'), false if not valid_signature
    @nonceStore.isNew req.body.oauth_nonce, req.body.oauth_timestamp, (err, valid) ->
      if not valid
        callback new errors.NonceError('Expired nonce'), false
      else
        callback null, true


  # Stores the request's properties into the @body accessor
  #  Strips 'oauth_' parameters for saftey
  #
  # Does not return anything
  parse_request: (req) =>
    for key, val of req.body
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

    # Outcomes for the 1.1 gradebook extension
    if (@body.lis_outcome_service_url and @body.lis_result_sourcedid)
      # The LTI 1.1 spec says that the language parameter is usually implied to be en, so the OutcomeService object
      # defaults to en until the spec updates and says there's other possible format options.
      @outcome_service = new OutcomeService @body.lis_outcome_service_url, @body.lis_result_sourcedid, @
    else
      @outcome_service = false;

    # user
    @username = @body.lis_person_name_given or @body.lis_person_name_family or @body.lis_person_name_full or ''
    @userId   = @body.user_id

    @mentor_user_ids = (decodeURIComponent(id) for id in @body.role_scope_mentor.split ',') if typeof @body.role_scope_mentor is 'string'

    # Context information
    @context_id     = @body.context_id
    @context_label  = @body.context_label
    @context_title  = @body.context_title


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
