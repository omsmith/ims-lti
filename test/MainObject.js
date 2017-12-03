/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const lti       = require('../');
const should    = require('should');


describe('LTI', function() {

  before(()=> {
    return this.lti = lti;
  });

  describe('.Provider', () => {
    it('should exist', () => {
      return should.exist(this.lti.Provider);
    });

    return it('should be an instance of Provider', () => {
      this.lti.Provider.should.be.an.instanceOf(Object);
      return this.lti.Provider.should.equal(require(('../src/provider')));
    });
  });


  describe('.Consumer', () => {
    it('should exist', () => {
      return should.exist(this.lti.Consumer);
    });

    return it('should be an instance of Consumer', () => {
      this.lti.Consumer.should.be.an.instanceOf(Object);
      return this.lti.Consumer.should.equal(require(('../src/consumer')));
    });
  });

  return describe('.Stores', () => {
    it('should not be empty', () => {
      return should.exist(this.lti.Stores);
    });
    return it('should include NonceStore', () => {
      return should.exist(this.lti.Stores.NonceStore);
    });
  });
});
