/*
 * decaffeinate suggestions:
 * DS001: Remove Babel/TypeScript constructor workaround
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const NonceStore = require('./nonce-store');

// Five minutes
const EXPIRE_IN_SEC = 5*60;

class RedisNonceStore extends NonceStore {

  constructor(redisClient) {
    {
      // Hack: trick Babel/TypeScript into allowing this before super.
      if (false) { super(); }
      let thisFn = (() => { this; }).toString();
      let thisName = thisFn.slice(thisFn.indexOf('{') + 1, thisFn.indexOf(';')).trim();
      eval(`${thisName} = this;`);
    }
    if ((typeof redisClient === 'string') && (arguments.length === 2)) {
      redisClient = arguments[1];
    }
    this.redis = redisClient;
  }

  isNew(nonce, timestamp, next){

    if (next == null) { next = function(){}; }
    if ((typeof nonce === 'undefined') || (nonce === null) || (typeof nonce === 'function') || (typeof timestamp === 'function') || (typeof timestamp === 'undefined')) {
      return next(new Error('Invalid parameters'), false);
    }

    if ((typeof timestamp === 'undefined') || (timestamp === null)) {
      return next(new Error('Timestamp required'), false);
    }


    // Generate unix time in seconds
    const currentTime = Math.round(Date.now()/1000);
    // Make sure this request is fresh (within the grace period)
    const freshTimestamp = (currentTime - parseInt(timestamp,10)) <= EXPIRE_IN_SEC;

    if (!freshTimestamp) {
      return next(new Error('Expired timestamp'), false);
    }

    // Pass all the parameter checks, now check to see if used
    return this.redis.get(nonce, (err, seen) => {
      if (seen) {
        return next(new Error('Nonce already seen'), false);
      }
      // Dont have to wait for callback b/c it's a sync op
      this.setUsed(nonce, timestamp);
      return next(null, true);
    });
  }


  setUsed(nonce, timestamp, next){
    if (next == null) { next = function(){}; }
    this.redis.set(nonce, timestamp);
    this.redis.expire(nonce, EXPIRE_IN_SEC);
    return next(null);
  }
}


const exports = (module.exports = RedisNonceStore);
