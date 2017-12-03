/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * DS205: Consider reworking code to avoid use of IIFEs
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const HMAC_SHA1         = require('./hmac-sha1');
const MemoryNonceStore  = require('./memory-nonce-store');
const errors            = require('./errors');
const extensions        = require('./extensions');



class Provider {
  constructor(consumer_key, consumer_secret, nonceStore, signature_method ) {

    this.valid_request = this.valid_request.bind(this);
    this.parse_request = this.parse_request.bind(this);
    if (signature_method == null) { signature_method = new HMAC_SHA1(); }
    if ((typeof consumer_key === 'undefined') || (consumer_key === null)) {
      throw new errors.ConsumerError('Must specify consumer_key');
    }

    if ((typeof consumer_secret === 'undefined') || (consumer_secret === null)) {
      throw new errors.ConsumerError('Must specify consumer_secret');
    }

    if (!nonceStore) {
      nonceStore = new MemoryNonceStore();
    }

    if (!(typeof nonceStore.isNonceStore === 'function' ? nonceStore.isNonceStore() : undefined)) {
      throw new errors.ParameterError('Fourth argument must be a nonceStore object');
    }

    this.consumer_key     = consumer_key;
    this.consumer_secret  = consumer_secret;
    this.signer           = signature_method;
    this.nonceStore       = nonceStore;
    this.body             = {};
  }


  // Verify parameter and OAuth signature by passing the request object
  // Returns true/false if is valid
  //
  // Sets up request variables for easier access down the line
  valid_request(req, body, callback) {
    if (!callback) {
      callback = body;
      body = undefined;
    }

    body = body || req.body || req.payload;
    callback = callback || function() {};

    this.parse_request(req, body);

    if (!this._valid_parameters(body)) {
      return callback(new errors.ParameterError('Invalid LTI parameters'), false);
    }

    return this._valid_oauth(req, body, callback);
  }


  // Helper to validate basic LTI parameters
  //
  // Returns true/false if is valid LTI request
  _valid_parameters(body) {
    if (!body) {
      return false;
    }

    const correct_version      = require('./ims-lti').supported_versions.indexOf(body.lti_version) !== -1;
    const has_resource_link_id = (body.resource_link_id != null);
    const omits_content_item_params = 
      (body.resource_link_id == null) &&
      (body.resource_link_title == null) && 
      (body.resource_link_description == null) && 
      (body.launch_presentation_return_url == null) &&
      (body.lis_result_sourcedid == null);
    return (correct_version &&
      ( (body.lti_message_type === 'basic-lti-launch-request') && has_resource_link_id )) ||
      ( (body.lti_message_type === 'ContentItemSelectionRequest') && omits_content_item_params );
  }

  // Helper to validate the OAuth information in the request
  //
  // Returns true/false if is valid OAuth signatue and nonce
  _valid_oauth(req, body, callback) {
    const generated = this.signer.build_signature(req, body, this.consumer_secret);
    const valid_signature = generated === body.oauth_signature;
    if (!valid_signature) { return callback(new errors.SignatureError('Invalid Signature'), false); }
    return this.nonceStore.isNew(body.oauth_nonce, body.oauth_timestamp, function(err, valid) {
      if (!valid) {
        return callback(new errors.NonceError('Expired nonce'), false);
      } else {
        return callback(null, true);
      }
    });
  }


  // Stores the request's properties into the @body accessor
  //  Strips 'oauth_' parameters for saftey
  //
  // Does not return anything
  parse_request(req, body) {
    body = body || req.body || req.payload;

    for (let key in body) {
      const val = body[key];
      if (key.match(/^oauth_/)) { continue; }
      this.body[key] = val;
    }

    if (typeof this.body.roles === 'string') { this.body.roles = this.body.roles.split(','); }

    this.admin = this.has_role('Administrator');
    this.alumni = this.has_role('Alumni');
    this.content_developer = this.has_role('ContentDeveloper');
    this.guest = this.has_role('Guest');
    this.instructor = this.has_role('Instructor') || this.has_role('Faculty') || this.has_role('Staff');
    this.manager = this.has_role('Manager');
    this.member = this.has_role('Member');
    this.mentor = this.has_role('Mentor');
    this.none = this.has_role('None');
    this.observer = this.has_role('Observer');
    this.other = this.has_role('Other');
    this.prospective_student = this.has_role('ProspectiveStudent');
    this.student = this.has_role('Learner') || this.has_role('Student');
    this.ta = this.has_role('TeachingAssistant');

    this.launch_request = this.body.lti_message_type === 'basic-lti-launch-request';

    // user
    this.username = this.body.lis_person_name_given || this.body.lis_person_name_family || this.body.lis_person_name_full || '';
    this.userId   = this.body.user_id;

    if (typeof this.body.role_scope_mentor === 'string') { this.mentor_user_ids = (Array.from(this.body.role_scope_mentor.split(',')).map((id) => decodeURIComponent(id))); }

    // Context information
    this.context_id     = this.body.context_id;
    this.context_label  = this.body.context_label;
    this.context_title  = this.body.context_title;

    // Load up the extensions!
    return (() => {
      const result = [];
      for (let extension_name in extensions) {
        const extension = extensions[extension_name];
        result.push(extension.init(this));
      }
      return result;
    })();
  }


  // has_role Helper
  has_role(role) {
    // There's 3 different types of roles: system, institution, and context. Each one has their own unique identifier
    // string within the urn prefix. This regular expression can verify the prefix is there at all, and if it is, ensure
    // that it matches one of the three different ways that it can be formatted. Additionally, context roles can have a
    // suffix that futher describes what the role may be (such as an instructor that is a lecturer). Those details are
    // probably a bit too specific for most cases, so we can just verify that they are optionally there.
    const regex = new RegExp(`^(urn:lti:(sys|inst)?role:ims/lis/)?${role}(/.+)?$`, 'i');
    return this.body.roles && this.body.roles.some(r => regex.test(r));
  }
}



const exports = (module.exports = Provider);
