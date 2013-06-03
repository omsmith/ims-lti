RedisNonceStore   = require '../lib/redis-nonce-store'
should            = require 'should'
shared            = require './shared'





describe 'RedisNonceStore', () ->

  shared.shouldBehaveLikeNonce () =>
    new RedisNonceStore 'consumer_key', require('redis').createClient()