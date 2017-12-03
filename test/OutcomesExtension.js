/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS208: Avoid top-level this
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const should  = require('should');

const shared  = require('./shared');
const lti     = require('../');


describe('LTI.Extensions.Outcomes', () => {
  before(() => {
    this.server    = shared.outcomesWebServer();
    this.provider  = new lti.Provider('key', 'secret');

    this.server.listen(1337, '127.0.0.1');

    const req = {
      url: '/test',
      method: 'POST',
      body: {
        ext_outcome_data_values_accepted: 'text,url',
        lis_outcome_service_url: "http://127.0.0.1:1337/service/url",
        lis_result_sourcedid: "12",
        lti_message_type: "basic-lti-launch-request",
        lti_version: "LTI-1p0"
      },
      get() { return 'localhost'; }
    };

    return this.provider.parse_request(req);
  });

  after(() => {
    this.server.close();
    return this.server = null;
  });

  describe('replace', () => {
    it('should be able to send a valid request', next => {
      return this.provider.outcome_service.send_replace_result(.5, (err, result) => {
        should.not.exist(err);
        result.should.equal(true);
        return next();
      });
    });

    it('should handle a result higher than 1', () => {
      return this.provider.outcome_service.send_replace_result(5, (err, result) => {
        should.exist(err);
        return result.should.equal(false);
      });
    });

    it('should handle a result lower than 0', () => {
      return this.provider.outcome_service.send_replace_result(-5, (err, result) => {
        should.exist(err);
        return result.should.equal(false);
      });
    });

    it('should handle a result that is undefined', () => {
      return this.provider.outcome_service.send_replace_result(null, (err, result) => {
        should.exist(err);
        return result.should.equal(false);
      });
    });

    it('should be able to send a text payload', () => {
      return this.provider.outcome_service.send_replace_result_with_text(.5, 'Hello, world!', (err, result) => {
        should.not.exist(err);
        return result.should.equal(true);
      });
    });

    it('should be able to send a text payload', () => {
      return this.provider.outcome_service.send_replace_result_with_url(.5, 'http://test.com', (err, result) => {
        should.not.exist(err);
        return result.should.equal(true);
      });
    });

    it('should not be able to send a payload that the consumer does not support', () => {
      const provider = new lti.Provider('key', 'secret');
      provider.parse_request({
        body: {
          ext_outcome_data_values_accepted: 'url',
          lis_outcome_service_url: "http://127.0.0.1:1337/service/url",
          lis_result_sourcedid: "12"
        }
      });

      return provider.outcome_service.send_replace_result_with_text(.5, 'Hello, world!', (err, result) => {
        should.exist(err);
        return result.should.equal(false);
      });
    });
      
    return it('should return the error message from the response', next => {
      const provider = new lti.Provider('key', 'wrong_secret');
      provider.parse_request({
        body: {
          lis_outcome_service_url: "http://127.0.0.1:1337/service/url",
          lis_result_sourcedid: "12"
        }
      });

      return provider.outcome_service.send_replace_result(0, (err, result) => {
        should.exist(err);
        err.message.should.equal('The signature provided is not valid');
        result.should.equal(false);
        return next();
      });
    });
  });


  describe('read', () => {
    return it('should be able to read a result given an id', next => {
      return this.provider.outcome_service.send_read_result((err, result) => {
        should.not.exist(err);
        result.should.equal(.5);
        return next();
      });
    });
  });

  return describe('delete', () => {
    return it('should be able to delete a result given an id', next => {
      return this.provider.outcome_service.send_delete_result((err, result) => {
        should.not.exist(err);
        result.should.equal(true);
        return next();
      });
    });
  });
});
