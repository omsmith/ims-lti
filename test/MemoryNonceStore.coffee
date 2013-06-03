MemoryNonceStore  = require '../lib/memory-nonce-store'
should            = require 'should'
shared            = require './shared'

describe 'MemoryNonceStore', () ->

  shared.shouldBehaveLikeNonce () =>
    new MemoryNonceStore('consumer_key')