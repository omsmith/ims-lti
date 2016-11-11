should    = require 'should'

lti       = require '../'


describe 'LTI.consumer', () ->

  before ()=>
    @lti = lti

  describe 'Initialization', () =>
    it 'should accept (consumer_key, consumer_secret)', () =>
      sig = new (require '../lib/hmac-sha1')
      consumer_key = '10204'
      consumer_secret = 'secret-shhh'

      consumer = new @lti.Consumer(consumer_key,consumer_secret)

      consumer.should.be.an.instanceOf Object
      consumer.consumer_key.should.equal consumer_key
      consumer.consumer_secret.should.equal consumer_secret
      consumer.signer.toString().should.equal sig.toString()

    it 'should throw an error if no consumer_key or consumer_secret', () =>
      (()=>consumer = new @lti.Consumer()).should.throw(lti.Errors.ConsumerError)
      (()=>consumer = new @lti.Consumer('consumer-key')).should.throw(lti.Errors.ConsumerError)

  describe 'Structure', () =>
    before () =>
      @consumer = new @lti.Consumer('key','secret')
    it 'should have sign_request method', () =>
      should.exist @consumer.sign_request
      @consumer.sign_request.should.be.a.Function

  describe '.sign_request validation', () =>

    before () =>
      @consumer = new @lti.Consumer('key','secret')

    it 'should throw an error if no url', () =>
      (()=>@consumer.sign_request()).should.throw(lti.Errors.ConsumerError)

    it 'should throw an error if url is empty', () =>
      (()=>@consumer.sign_request('')).should.throw(lti.Errors.ConsumerError)

    it 'should throw an error if body is not an object', () =>
      (()=>@consumer.sign_request('http://blah.com', 'POST', 'bad')).should.throw(lti.Errors.ConsumerError)    

    it 'should return signed body params if method or body is empty or null', () =>
      signedKeyBothEmpty = @consumer.sign_request('http://blah.com')
      signedKeyBothEmpty.should.not.equal null

      signedKeyBodyEmpty = @consumer.sign_request('http://blah.com', 'POST')
      signedKeyBodyEmpty.should.not.equal.null

      signedKeyMethodEmpty = @consumer.sign_request('http://blah.com', null, {})
      signedKeyMethodEmpty.should.not.equal.null

  describe '.sign_request signing', () =>
    before () =>
      @consumer = new @lti.Consumer('key','secret')
      @provider = new @lti.Provider('key','secret')

      @req =
        url: '/test'
        method: 'POST'
        connection:
          encrypted: undefined
        headers:
          host: 'localhost'
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
          oauth_timestamp: Math.round(Date.now() / 1000)
          oauth_version: "1.0"
          resource_link_description: "<p>A test of the student's wits </p>"
          resource_link_id: "1"
          resource_link_title: "Fun LTI example!"
          roles: "Learner"
          role_scope_mentor: "1234,5678,12%2C34"
          tool_consumer_info_product_family_code: "moodle"
          tool_consumer_info_version: "2013051400"
          tool_consumer_instance_guid: "localhost"
          user_id: "4"

    it 'should return valid signed body', () =>
      @req.body.oauth_signature = @provider.signer.build_signature(@req, 'secret')
      signedBody = @consumer.sign_request(@req.url, @req.method, @req.body);

      signedBody.should.equal @req.body
