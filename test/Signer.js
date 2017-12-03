/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const HMAC_SHA1 = require('../src/hmac-sha1');

const signer = new HMAC_SHA1;

describe('Signer', () =>

  it('should include query params', function(done) {
    const req = {
      url: '/developers/LTI/test/v1p1/tool.php?foo=123&foo=bar',
      method: 'POST',
      connection: {
        encrypted: undefined
      },
      headers: {
        host: 'www.imsglobal.org'
      }
    };
    const body = {
      resource_link_id: 'rsc1',
      oauth_callback: 'about:blank',
      lis_outcome_service_url: 'http://www.imsglobal.org/developers/LTI/test/v1p1/common/tool_consumer_outcome.php?b64=MTIzNDU6OjpzZWNyZXQ=',
      lis_result_sourcedid: 'feb-123-456-2929::28883',
      launch_presentation_return_url: 'http://www.imsglobal.org/developers/LTI/test/v1p1/lms_return.php',
      lti_version: 'LTI-1p0',
      lti_message_type: 'basic-lti-launch-request',
      oauth_version: '1.0',
      oauth_nonce: '7ee33f6dc94117e792ff529898ce3953',
      oauth_timestamp: '1397708483',
      oauth_consumer_key: '12345',
      oauth_signature_method: 'HMAC-SHA1',
      oauth_signature: 'dHORwwJqwh5hQQAlvaA9csSIOhc='
    };

    const signature = signer.build_signature(req, body, 'secret');
    signature.should.equal(body.oauth_signature);

    return done();
  })
);
