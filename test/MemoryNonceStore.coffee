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


  describe '.setUsed', () =>
    it 'should exist', () =>
      should.exist(@store.setUsed)

    it 'should set nonces to used', () =>
      store = new MemoryNonceStore('consumer_key')
      store.setUsed('1')
      store.isNew('1').should.not.be.ok