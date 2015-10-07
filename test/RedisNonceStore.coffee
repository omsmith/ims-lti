redis             = require 'redis'
should            = require 'should'

RedisNonceStore   = require '../lib/redis-nonce-store'
shared            = require './shared'

describe 'RedisNonceStore', () ->

  redisClient = redis.createClient()

  shared.shouldBehaveLikeNonce () =>
    new RedisNonceStore redisClient

  it 'should put the client on redis property (private)', () ->
    store = new RedisNonceStore redisClient

    store.redis.should.equal redisClient

  it 'should ignore old consumer_key arg as first argument', () ->
    store = new RedisNonceStore 'consumer_key', redisClient

    store.redis.should.equal redisClient

