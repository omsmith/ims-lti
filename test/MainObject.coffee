lti       = require '../'
should    = require 'should'


describe 'Main', () ->

  before ()=>
    @lti = lti

  describe '.Provider', () =>
    it 'should exist', () =>
      should.exist(@lti.Provider)

    it 'should be an instance of Provider', () =>
      @lti.Provider.should.be.an.instanceOf Object
      @lti.Provider.should.equal require ('../lib/provider')


  describe '.Consumer', () =>
    it 'should exist', () =>
      should.exist(@lti.Consumer)

    it 'should be an instance of Consumer', () =>
      @lti.Consumer.should.be.an.instanceOf Object
      @lti.Consumer.should.equal require ('../lib/consumer')

  describe '.supported_versions', () =>
    it 'should not be empty', () =>
      @lti.supported_versions.length.should.not.equal 0
    it 'should include 1.0', () =>
      @lti.supported_versions.should.include '1.0'
    it 'should include 1.1', () =>
      @lti.supported_versions.should.include '1.1'