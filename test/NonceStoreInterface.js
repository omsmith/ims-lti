/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const NonceStore  = require('../lib/nonce-store');
const should            = require('should');


describe('NonceStore [Interface Class]', function() {

  before(()=> {
    return this.store = new NonceStore('consumer_key');
  });


  // Standard nonce tests
  //
  //-- do not change below this line--

  describe('NonceStore', () => {
    return it('should have extend NonceStore', () => {
      should.exist(this.store.isNonceStore);
      return this.store.isNonceStore().should.be.ok;
    });
  });

  describe('.isNew', () => {
    it('should exist', () => {
      return should.exist(this.store.isNew);
    });

    return it('should return Not Implemented', done => {
      return this.store.isNew(undefined, undefined, function(err, valid){
        err.should.not.equal(null);
        err.message.should.match(/NOT/i);
        valid.should.equal(false);
        return done();
      });
    });
  });


  return describe('.setUsed', () => {
    it('should exist', () => {
      return should.exist(this.store.setUsed);
    });

    return it('should return Not Implemented', done => {
      return this.store.setUsed(undefined, undefined, function(err, valid){
        err.should.not.equal(null);
        err.message.should.match(/NOT/i);
        valid.should.equal(false);
        return done();
      });
    });
  });
});

