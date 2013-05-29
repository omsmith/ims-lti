MemoryNonceStore  = require '../lib/memory-nonce-store'
should            = require 'should'


describe 'MemoryNonceStore', () ->

  before ()=>
    @store = new MemoryNonceStore('consumer_key')

  describe '.isNew', () =>
    it 'should exist', () =>
      should.exist(@store.isNew)

    it 'should return true for new nonces', () =>
      store = new MemoryNonceStore('consumer_key')
      store.isNew('1').should.be.ok
      store.isNew('2').should.be.ok
      store.isNew('a').should.be.ok
      store.isNew('z').should.be.ok

    it 'should return false for used nonces', () =>
      store = new MemoryNonceStore('consumer_key')
      store.isNew('1').should.be.ok
      store.isNew('1').should.not.be.ok
      store.isNew('a').should.be.ok
      store.isNew('a').should.not.be.ok


    it 'should return true for time-relivant nonces', () =>
      store = new MemoryNonceStore('consumer_key')

      now = Math.round(Date.now()/1000)
      future = now+1*60
      past_minute = now - 1*60
      past_two_minutes = now - 2*60

      store.isNew('00', now).should.be.ok
      store.isNew('11', future).should.be.ok
      store.isNew('01', past_minute).should.be.ok
      store.isNew('02', past_two_minutes).should.be.ok


    it 'should return false for expired nonces', () =>
      store = new MemoryNonceStore('consumer_key')

      now = Math.round(Date.now()/1000)
      five_and_one_sec_old = now-5*60-1
      hour_old = now-60*60

      store.isNew('00', five_and_one_sec_old).should.not.be.ok
      store.isNew('11', hour_old).should.not.be.ok

  describe '.setUsed', () =>
    it 'should exist', () =>
      should.exist(@store.setUsed)

    it 'should set nonces to used', () =>
      store = new MemoryNonceStore('consumer_key')
      store.setUsed('1')
      store.isNew('1').should.not.be.ok