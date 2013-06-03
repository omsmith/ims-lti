RedisNonceStore   = require '../lib/memory-nonce-store'
should            = require 'should'
shared            = require './shared'


client = require('redis').createClient()


describe 'RedisNonceStore', () ->

  shared.shouldBehaveLikeNonce () =>
    new RedisNonceStore('consumer_key', client)