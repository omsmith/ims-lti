/*
 * decaffeinate suggestions:
 * DS001: Remove Babel/TypeScript constructor workaround
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const NonceStore = require('./nonce-store');

// Five minutes
const EXPIRE_IN_SEC = 5 * 60;

class MemoryNonceStore extends NonceStore {

  constructor() {
    super();
    this.used = Object.create(null);
  }

  isNew(nonce, timestamp, next){

    if (next == null) { next = function(){}; }
    if ((typeof nonce === 'undefined') || (nonce === null) || (typeof nonce === 'function') || (typeof timestamp === 'function') || (typeof timestamp === 'undefined')) {
      return next(new Error('Invalid parameters'), false);
    }

    this._clearNonces();

    const firstTimeSeen = this.used[nonce] === undefined;

    if (!firstTimeSeen) {
      return next(new Error('Nonce already seen'), false);
    }

    return this.setUsed(nonce, timestamp, function(err) {
      if ((typeof timestamp !== 'undefined') && (timestamp !== null)) {
        timestamp = parseInt(timestamp, 10);
        const currentTime = Math.round(Date.now() / 1000);

        const timestampIsFresh = (currentTime - timestamp) <= EXPIRE_IN_SEC;

        if (timestampIsFresh) {
          return next(null, true);
        } else {
          return next(new Error('Expired timestamp'), false);
        }
      } else {
        return next(new Error('Timestamp required'), false);
      }
    });
  }

  setUsed(nonce, timestamp, next){
    if (next == null) { next = function(){}; }
    this.used[nonce] = timestamp + EXPIRE_IN_SEC;
    return next(null);
  }

  _clearNonces() {
    const now = Math.round(Date.now() / 1000);

    for (let nonce in this.used) {
      const expiry = this.used[nonce];
      if (expiry <= now) { delete this.used[nonce]; }
    }

  }
}


module.exports = MemoryNonceStore;
