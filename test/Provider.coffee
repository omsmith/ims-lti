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



    it 'should accept (consumer_key, consumer_secret, sig)', () =>
      sig =
        me: 3
        you: 1
        total: 4

      provider = new @lti.Provider('10204','secret-shhh',sig)
      provider.signer.should.equal sig


    it 'should accept (consumer_key, consumer_secret, sig, nonceStore)', () =>
      nonceStore =
        isNonceStore: ()->true
        isNew:   ()->return
        setUsed: ()->return

      provider = new @lti.Provider('10204','secret-shhh',{}, nonceStore)
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
      @signer = @provider.signature_method

    it 'should return false if missing lti_message_type', (done) =>
      req_missing_type =
        body:
          lti_message_type: ''
          lti_version: 'LTI-1p0'
          resource_link_id: 'http://link-to-resource.com/resource'
      @provider.valid_request req_missing_type, (err, valid) ->
        err.should.be.an Error
        valid.should.equal false

    it 'should return false if incorrect LTI version', (done) =>
      req_wrong_version =
        body:
          lti_message_type: 'basic-lti-launch-request'
          lti_version: 'LTI-0p0'
          resource_link_id: 'http://link-to-resource.com/resource'
      @provider.valid_request req_wrong_version, (err, valid) ->
        err.should.be.an Error
        valid.should.equal false


    it 'should return false if no resource_link_id', (done) =>
      req_no_resource_link =
        body:
          lti_message_type: 'basic-lti-launch-request'
          lti_version: 'LTI-1p0'
      @provider.valid_request req_no_resource_link, (err, valid) ->
        err.should.be.an Error
        valid.should.equal false

    it 'should return false if bad oauth', (done) =>
      req =
        path: '/test'
        route: {method: 'POST'}
        body:
          lti_message_type: 'basic-lti-launch-request'
          lti_version: 'LTI-1p0'
          resource_link_id: 'http://link-to-resource.com/resource'
          oauth_customer_key: 'key'
          oauth_signature_method: 'HMAC-SHA1'

      #sign the fake request
      signature = @provider.signer.build_signature(req, 'secret')
      req.body.oauth_signature = signature

      # Break the signature
      req.body.oauth_signature += "garbage"

      @provider.valid_request req, (err, valid) ->
        err.should.be.an Error
        valid.should.equal false



    it 'should return true if good headers and oauth', (done) =>
      req =
        path: '/test'
        route: {method: 'POST'}
        body:
          lti_message_type: 'basic-lti-launch-request'
          lti_version: 'LTI-1p0'
          resource_link_id: 'http://link-to-resource.com/resource'
          oauth_customer_key: 'key'
          oauth_signature_method: 'HMAC-SHA1'
          oauth_timestamp: Math.round(Date.now()/1000)
          oauth_nonce: Date.now()

      #sign the fake request
      signature = @provider.signer.build_signature(req, 'secret')
      req.body.oauth_signature = signature

      @provider.valid_request req, (err, valid) ->
        err.should.equal null
        valid.should.equal true


    it 'should return false if nonce already seen', () =>
      req =
        path: '/test'
        route: {method: 'POST'}
        body:
          lti_message_type: 'basic-lti-launch-request'
          lti_version: 'LTI-1p0'
          resource_link_id: 'http://link-to-resource.com/resource'
          oauth_customer_key: 'key'
          oauth_signature_method: 'HMAC-SHA1'
          oauth_timestamp: Math.round(Date.now()/1000)
          oauth_nonce: Date.now()

      #sign the fake request
      signature = @provider.signer.build_signature(req, 'secret')
      req.body.oauth_signature = signature

      @provider.valid_request(req).should.equal true
      # Stall for a moment
      @provider.valid_request(req)
      @provider.valid_request(req).should.equal false





