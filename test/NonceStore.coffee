NonceStore  = require '../lib/nonce-store'
should            = require 'should'


describe 'NonceStore [Interface Class]', () ->

  before ()=>
    @store = new NonceStore('consumer_key')


  # Standard nonce tests
  #
  #-- do not change below this line--

  describe 'NonceStore', () =>
    it 'should have extend NonceStore', () =>
      should.exist(@store.isNonceStore)
      @store.isNonceStore().should.be.ok

  describe '.isNew', () =>
    it 'should exist', () =>
      should.exist(@store.isNew)

    it 'should return Not Implemented', (done) =>
      @store.isNew undefined, undefined, (err, valid)->
        err.should.not.equal null
        err.message.should.match /NOT/i
        valid.should.equal false
        done()


  describe '.setUsed', () =>
    it 'should exist', () =>
      should.exist(@store.setUsed)

    it 'should return Not Implemented', (done) =>
      @store.setUsed undefined, undefined, (err, valid)->
        err.should.not.equal null
        err.message.should.match /NOT/i
        valid.should.equal false
        done()