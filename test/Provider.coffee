lti       = require '../'
should    = require 'should'


describe 'Main.Provider', () ->

  before ()=>
    @lti = lti

  describe 'Initialization', () =>
    it 'should accept (consumer_key, consumer_secret, params)', () =>

      consumer_key = '10204'
      consumer_secret = 'secret-shhh'
      params =
        me: 3
        you: 1
        total: 4

      provider = new @lti.Provider(consumer_key,consumer_secret,params)

      provider.should.be.an.instanceOf Object
      provider.consumer_key.should.equal consumer_key
      provider.consumer_secret.should.equal consumer_secret
      provider.config.should.equal params

    it 'should throw an error if no consumer_key or consumer_secret', () =>
      (()=>provider = new @lti.Provider()).should.throw()
      (()=>provider = new @lti.Provider('consumer-key')).should.throw()

