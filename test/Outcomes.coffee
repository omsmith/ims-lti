should  = require 'should'

shared  = require './shared'
lti     = require '../'


describe 'LTI.Outcomes', () =>
  before () =>
    @server    = shared.outcomesWebServer()
    @provider  = new lti.Provider 'key', 'secret'

    @server.listen 1337, '127.0.0.1'

    req =
      url: '/test'
      method: 'POST'
      body:
        lis_outcome_service_url: "http://127.0.0.1:1337/service/url"
        lis_result_sourcedid: "12"
        lti_message_type: "basic-lti-launch-request"
        lti_version: "LTI-1p0"
      get: () -> 'localhost'

    @provider.parse_request req

  after () =>
    @server.close()
    @server = null

  describe 'replace', () =>
    it 'should be able to send a valid request', (next) =>
      @provider.outcome_service.send_replace_result .5, (err, result) =>
        should.not.exist err
        result.should.equal true
        next()

    it 'should handle a result higher than 1', () =>
      (() =>
        @provider.outcome_service.send_replace_result 5, null
      ).should.throw()

    it 'should handle a result lower than 0', () =>
      (() =>
        @provider.outcome_service.send_replace_result -5, null
      ).should.throw()

    it 'should handle a result that is undefined', () =>
      (() =>
        @provider.outcome_service.send_replace_result null, null
      ).should.throw()

  describe 'read', () =>
    it 'should be able to read a result given an id', (next) =>
      @provider.outcome_service.send_read_result (err, result) =>
        should.not.exist err
        result.should.equal .5
        next()

  describe 'delete', () =>
    it 'should be able to delete a result given an id', (next) =>
      @provider.outcome_service.send_delete_result (err, result) =>
        should.not.exist err
        result.should.equal true
        next()
