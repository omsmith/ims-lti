/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const redis             = require('redis');
const RedisNonceStore   = require('../src/redis-nonce-store');
const shared            = require('./shared');

describe('RedisNonceStore', function() {

  const redisClient = redis.createClient();

  shared.shouldBehaveLikeNonce(() => {
    return new RedisNonceStore(redisClient);
  });

  it('should put the client on redis property (private)', function() {
    const store = new RedisNonceStore(redisClient);

    return store.redis.should.equal(redisClient);
  });

  return it('should ignore old consumer_key arg as first argument', function() {
    const store = new RedisNonceStore('consumer_key', redisClient);

    return store.redis.should.equal(redisClient);
  });
});
