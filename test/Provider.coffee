lti       = require '../'
should    = require 'should'


describe 'LTI.Provider', () ->

  before ()=>
    @lti = lti

  describe 'Initialization', () =>
    it 'should accept (consumer_key, consumer_secret)', () =>

      sig = new (require '../lib/hmac-sha1')
      consumer_key = '10204'
      consumer_secret = 'secret-shhh'

      provider = new @lti.Provider(consumer_key,consumer_secret)

      provider.should.be.an.instanceOf Object
      provider.consumer_key.should.equal consumer_key
      provider.consumer_secret.should.equal consumer_secret
      provider.signer.toString().should.equal sig.toString()



    it 'should accept (consumer_key, consumer_secret, nonceStore, sig)', () =>
      sig =
        me: 3
        you: 1
        total: 4

      provider = new @lti.Provider('10204','secret-shhh', undefined, sig)
      provider.signer.should.equal sig


    it 'should accept (consumer_key, consumer_secret, nonceStore, sig)', () =>
      nonceStore =
        isNonceStore: ()->true
        isNew:   ()->return
        setUsed: ()->return

      provider = new @lti.Provider('10204','secret-shhh',nonceStore)
      provider.nonceStore.should.equal nonceStore


    it 'should throw an error if no consumer_key or consumer_secret', () =>
      (()=>provider = new @lti.Provider()).should.throw()
      (()=>provider = new @lti.Provider('consumer-key')).should.throw()


  describe 'Structure', () =>
    before () =>
      @provider = new @lti.Provider('key','secret')
    it 'should have valid_request method', () =>
      should.exist @provider.valid_request
      @provider.valid_request.should.be.a('function')



  describe '.valid_request method', () =>

    before () =>
      @provider = new @lti.Provider('key','secret')
      @signer = @provider.signer

    it 'should return false if missing lti_message_type', (done) =>
      req_missing_type =
        body:
          lti_message_type: ''
          lti_version: 'LTI-1p0'
          resource_link_id: 'http://link-to-resource.com/resource'
      @provider.valid_request req_missing_type, (err, valid) ->
        err.should.not.equal null
        valid.should.equal false
        done()

    it 'should return false if incorrect LTI version', (done) =>
      req_wrong_version =
        body:
          lti_message_type: 'basic-lti-launch-request'
          lti_version: 'LTI-0p0'
          resource_link_id: 'http://link-to-resource.com/resource'
      @provider.valid_request req_wrong_version, (err, valid) ->
        err.should.not.equal null
        valid.should.equal false
        done()


    it 'should return false if no resource_link_id', (done) =>
      req_no_resource_link =
        body:
          lti_message_type: 'basic-lti-launch-request'
          lti_version: 'LTI-1p0'
      @provider.valid_request req_no_resource_link, (err, valid) ->
        err.should.not.equal null
        valid.should.equal false
        done()

    it 'should return false if bad oauth', (done) =>
      req =
        path: '/test'
        method: 'POST'
        body:
          lti_message_type: 'basic-lti-launch-request'
          lti_version: 'LTI-1p0'
          resource_link_id: 'http://link-to-resource.com/resource'
          oauth_customer_key: 'key'
          oauth_signature_method: 'HMAC-SHA1'
          oauth_timestamp: Math.round(Date.now()/1000)
          oauth_nonce: Date.now()+Math.random()*100
        get: () -> 'test-get'

      #sign the fake request
      signature = @provider.signer.build_signature(req, 'secret')
      req.body.oauth_signature = signature

      # Break the signature
      req.body.oauth_signature += "garbage"

      @provider.valid_request req, (err, valid) ->
        err.should.not.equal null
        valid.should.equal false
        done()



    it 'should return true if good headers and oauth', (done) =>
      req =
        path: '/test'
        method: 'POST'
        body:
          lti_message_type: 'basic-lti-launch-request'
          lti_version: 'LTI-1p0'
          resource_link_id: 'http://link-to-resource.com/resource'
          oauth_customer_key: 'key'
          oauth_signature_method: 'HMAC-SHA1'
          oauth_timestamp: Math.round(Date.now()/1000)
          oauth_nonce: Date.now()+Math.random()*100
        get: () -> 'test-get'

      #sign the fake request
      signature = @provider.signer.build_signature(req, 'secret')
      req.body.oauth_signature = signature

      @provider.valid_request req, (err, valid) ->
        should.not.exist err
        valid.should.equal true
        done()


    it 'should return false if nonce already seen', (done) =>
      req =
        path: '/test'
        method: 'POST'
        body:
          lti_message_type: 'basic-lti-launch-request'
          lti_version: 'LTI-1p0'
          resource_link_id: 'http://link-to-resource.com/resource'
          oauth_customer_key: 'key'
          oauth_signature_method: 'HMAC-SHA1'
          oauth_timestamp: Math.round(Date.now()/1000)
          oauth_nonce: Date.now()+Math.random()*100
        get: () -> 'test-gets'

      #sign the fake request
      signature = @provider.signer.build_signature(req, 'secret')
      req.body.oauth_signature = signature

      @provider.valid_request req, (err, valid) =>
        should.not.exist err
        valid.should.equal true
        @provider.valid_request req, (err, valid) ->
          should.exist err
          valid.should.equal false
          done()



  describe 'mapping', () =>

    before () =>
      @provider = new @lti.Provider('key','secret')

      req =
        path: '/test'
        method: 'POST'
        body:
          context_id: "4"
          context_label: "PHYS 2112"
          context_title: "Introduction To Physics"
          custom_param: "23"
          ext_lms: "moodle-2"
          ext_submit: "Press to launch this activity"
          launch_presentation_locale: "en"
          launch_presentation_return_url: "http://localhost:8888/moodle25/mod/lti/return.php?course=4&launch_container=4&instanceid=1"
          lis_outcome_service_url: "http://localhost:8888/moodle25/mod/lti/service.php"
          lis_person_contact_email_primary: "james@courseshark.com"
          lis_person_name_family: "Rundquist"
          lis_person_name_full: "James Rundquist"
          lis_person_name_given: "James"
          lis_result_sourcedid: "{\"data\":{\"instanceid\":\"1\",\"userid\":\"4\",\"launchid\":1480927086},\"hash\":\"03382572ba1bf35bcd99f9a9cbd44004c8f96f89c96d160a7b779a4ef89c70d5\"}"
          lti_message_type: "basic-lti-launch-request"
          lti_version: "LTI-1p0"
          oauth_callback: "about:blank"
          oauth_consumer_key: "moodle"
          oauth_nonce: Date.now()+Math.random()*100
          oauth_signature_method: "HMAC-SHA1"
          oauth_timestamp: Math.round(Date.now()/1000)
          oauth_version: "1.0"
          resource_link_description: "<p>A test of the student's wits </p>"
          resource_link_id: "1"
          resource_link_title: "Fun LTI example!"
          roles: "Learner"
          tool_consumer_info_product_family_code: "moodle"
          tool_consumer_info_version: "2013051400"
          tool_consumer_instance_guid: "localhost"
          user_id: "4"
        get: () -> 'some-host'

      #sign the request
      req.body.oauth_signature = @provider.signer.build_signature(req, 'secret')

      @provider.parse_request req

    it 'should create a filled @body', () =>
      should.exist @provider.body
      @provider.body.should.have.property('context_id')
      @provider.body.should.have.property('context_label')
      @provider.body.should.have.property('context_title')
      @provider.body.should.have.property('custom_param')
      @provider.body.should.have.property('ext_lms')
      @provider.body.should.have.property('ext_submit')
      @provider.body.should.have.property('launch_presentation_locale')
      @provider.body.should.have.property('launch_presentation_return_url')
      @provider.body.should.have.property('lis_outcome_service_url')
      @provider.body.should.have.property('lis_person_contact_email_primary')
      @provider.body.should.have.property('lis_person_name_family')
      @provider.body.should.have.property('lis_person_name_full')
      @provider.body.should.have.property('lis_person_name_given')
      @provider.body.should.have.property('lis_result_sourcedid')
      @provider.body.should.have.property('lti_message_type')
      @provider.body.should.have.property('lti_version')
      @provider.body.should.have.property('resource_link_description')
      @provider.body.should.have.property('resource_link_id')
      @provider.body.should.have.property('resource_link_title')
      @provider.body.should.have.property('roles')
      @provider.body.should.have.property('tool_consumer_info_product_family_code')
      @provider.body.should.have.property('tool_consumer_info_version')
      @provider.body.should.have.property('tool_consumer_instance_guid')
      @provider.body.should.have.property('user_id')

    it 'should have stripped oauth_ properties', () =>
      @provider.body.should.not.have.property('oauth_callback')
      @provider.body.should.not.have.property('oauth_consumer_key')
      @provider.body.should.not.have.property('oauth_nonce')
      @provider.body.should.not.have.property('oauth_signature')
      @provider.body.should.not.have.property('oauth_signature_method')
      @provider.body.should.not.have.property('oauth_timestamp')
      @provider.body.should.not.have.property('oauth_version')

    it 'should have helper booleans for roles', () =>
      @provider.student.should.equal true
      @provider.instructor.should.equal false
      @provider.content_developer.should.equal false
      @provider.member.should.equal false
      @provider.manager.should.equal false
      @provider.mentor.should.equal false
      @provider.admin.should.equal false
      @provider.ta.should.equal false

    it 'should have username accessor', () =>
      @provider.username.should.equal "James"

    it 'should have user id accessor', () =>
      @provider.userId.should.equal "4"

    it 'should have context accessors', () =>
      @provider.context_id.should.equal "4"
      @provider.context_label.should.equal "PHYS 2112"
      @provider.context_title.should.equal "Introduction To Physics"

    it 'should have response outcome_service boolean', () =>
      @provider.outcome_service.should.equal true

    it 'should account for the standardized urn prefix', () =>
      provider = new @lti.Provider('key', 'secret')
      provider.parse_request
        body:
          roles: 'urn:lti:role:ims/lis/Instructor'

      provider.instructor.should.equal true

    it 'should test for multiple roles being passed into the body', () =>
      provider = new @lti.Provider('key', 'secret')
      provider.parse_request
        body:
          roles: 'Instructor,Administrator'

      provider.instructor.should.equal true
      provider.admin.should.equal true
