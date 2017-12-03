/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const MemoryNonceStore  = require('../src/memory-nonce-store');
const shared            = require('./shared');


describe('MemoryNonceStore', () =>

  shared.shouldBehaveLikeNonce(() => {
    return new MemoryNonceStore();
  })
);
