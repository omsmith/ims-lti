url = require 'url'

lti = require '../'

describe 'LTI.Extensions.Content', () ->
  beforeEach () ->
    @provider = new lti.Provider 'key', 'secret'

    req =
      body:
        ext_content_return_types: 'file,iframe,image_url,lti_launch_url,oembed,url'
        ext_content_return_url: 'http://example.com/test'
        ext_content_file_extensions: 'txt,jpg'

    @res =
      status: null
      url: null
      redirect: (@status, @url) ->

    @provider.parse_request req


  describe 'constructor', () ->
    it 'should initialize an object if ext_content_return_types is set', () ->
      @provider.ext_content.should.exist

    it 'should be false if ext_content_return_types is missing', () ->
      provider = new lti.Provider 'key', 'secret'
      provider.parse_request { body: {} }
      provider.ext_content.should.equal false


  describe '_validate_return_type', () ->
    it 'should throw an exception if the type does not exist for the provider', () ->
      fn = () =>
        @provider.ext_content._validate_return_type 'invalid'

      fn.should.throw()


  describe 'has_return_type', () ->
    it 'should be able to check if a return type is set', () ->
      @provider.ext_content.has_return_type('file').should.equal true
      @provider.ext_content.has_return_type('iframe').should.equal true
      @provider.ext_content.has_return_type('fail').should.equal false


  describe 'has_file_extension', () ->
    it 'should be able to check if a file extension is set', () ->
      @provider.ext_content.has_file_extension('txt').should.equal true
      @provider.ext_content.has_file_extension('jpg').should.equal true
      @provider.ext_content.has_file_extension('rar').should.equal false


  describe 'send_file', () ->
    it 'should generate a query string for the base params and exclude optional ones', () ->
      @provider.ext_content.send_file @res, 'http://example.com/myfile.txt', 'myfile.txt'

      ret_url = url.parse @res.url, true

      @res.status.should.equal 303
      ret_url.query.return_type.should.equal 'file'
      ret_url.query.url.should.equal 'http://example.com/myfile.txt'
      ret_url.query.text.should.equal 'myfile.txt'
      ret_url.query.should.not.have.property 'content_type'

    it 'should generate a query string for the optional parameters', () ->
      @provider.ext_content.send_file @res, 'http://example.com/myfile.txt', 'myfile.txt', 'text/plain'

      ret_url = url.parse @res.url, true

      @res.status.should.equal 303
      ret_url.query.return_type.should.equal 'file'
      ret_url.query.url.should.equal 'http://example.com/myfile.txt'
      ret_url.query.text.should.equal 'myfile.txt'
      ret_url.query.content_type.should.equal 'text/plain'


  describe 'send_iframe', () ->
    it 'should generate a query string for the base params and exclude optional ones', () ->
      @provider.ext_content.send_iframe @res, 'http://example.com/myfile.txt'

      ret_url = url.parse @res.url, true

      @res.status.should.equal 303
      ret_url.query.return_type.should.equal 'iframe'
      ret_url.query.url.should.equal 'http://example.com/myfile.txt'
      ret_url.query.should.not.have.property 'title'
      ret_url.query.should.not.have.property 'width'
      ret_url.query.should.not.have.property 'height'

    it 'should generate a query string for the optional parameters', () ->
      @provider.ext_content.send_iframe @res, 'http://example.com/myfile.txt', 'title', 800, 600

      ret_url = url.parse @res.url, true

      @res.status.should.equal 303
      ret_url.query.return_type.should.equal 'iframe'
      ret_url.query.url.should.equal 'http://example.com/myfile.txt'
      ret_url.query.title.should.equal 'title'
      ret_url.query.width.should.equal '800'
      ret_url.query.height.should.equal '600'


  describe 'send_image_url', () ->
    it 'should generate a query string for the base params and exclude optional ones', () ->
      @provider.ext_content.send_image_url @res, 'http://example.com/myfile.jpg'

      ret_url = url.parse @res.url, true

      @res.status.should.equal 303
      ret_url.query.return_type.should.equal 'image_url'
      ret_url.query.url.should.equal 'http://example.com/myfile.jpg'
      ret_url.query.should.not.have.property 'text'
      ret_url.query.should.not.have.property 'width'
      ret_url.query.should.not.have.property 'height'

    it 'should generate a query string for the optional parameters', () ->
      @provider.ext_content.send_image_url @res, 'http://example.com/myfile.jpg', 'alt', 800, 600

      ret_url = url.parse @res.url, true

      @res.status.should.equal 303
      ret_url.query.return_type.should.equal 'image_url'
      ret_url.query.url.should.equal 'http://example.com/myfile.jpg'
      ret_url.query.text.should.equal 'alt'
      ret_url.query.width.should.equal '800'
      ret_url.query.height.should.equal '600'


  describe 'send_lti_launch_url', () ->
    it 'should generate a query string for the base params and exclude optional ones', () ->
      @provider.ext_content.send_lti_launch_url @res, 'http://example.com/test'

      ret_url = url.parse @res.url, true

      @res.status.should.equal 303
      ret_url.query.return_type.should.equal 'lti_launch_url'
      ret_url.query.url.should.equal 'http://example.com/test'
      ret_url.query.should.not.have.property 'title'
      ret_url.query.should.not.have.property 'text'

    it 'should generate a query string for the optional parameters', () ->
      @provider.ext_content.send_lti_launch_url @res, 'http://example.com/test', 'title', 'text'

      ret_url = url.parse @res.url, true

      @res.status.should.equal 303
      ret_url.query.return_type.should.equal 'lti_launch_url'
      ret_url.query.url.should.equal 'http://example.com/test'
      ret_url.query.title.should.equal 'title'
      ret_url.query.text.should.equal 'text'


  describe 'send_oembed', () ->
    it 'should generate a query string for the base params and exclude optional ones', () ->
      @provider.ext_content.send_oembed @res, 'http://example.com/test'

      ret_url = url.parse @res.url, true

      @res.status.should.equal 303
      ret_url.query.return_type.should.equal 'oembed'
      ret_url.query.url.should.equal 'http://example.com/test'
      ret_url.query.should.not.have.property 'endpoint'

    it 'should generate a query string for the optional parameters', () ->
      @provider.ext_content.send_oembed @res, 'http://example.com/test', 'http://example.com/test2'

      ret_url = url.parse @res.url, true

      @res.status.should.equal 303
      ret_url.query.return_type.should.equal 'oembed'
      ret_url.query.url.should.equal 'http://example.com/test'
      ret_url.query.endpoint.should.equal 'http://example.com/test2'


  describe 'send_url', () ->
    it 'should generate a query string for the base params and exclude optional ones', () ->
      @provider.ext_content.send_url @res, 'http://example.com/test'

      ret_url = url.parse @res.url, true

      @res.status.should.equal 303
      ret_url.query.return_type.should.equal 'url'
      ret_url.query.url.should.equal 'http://example.com/test'
      ret_url.query.should.not.have.property 'text'
      ret_url.query.should.not.have.property 'title'
      ret_url.query.should.not.have.property 'target'

    it 'should generate a query string for the optional parameters', () ->
      @provider.ext_content.send_url @res, 'http://example.com/test', 'text', 'title', '_blank'

      ret_url = url.parse @res.url, true

      @res.status.should.equal 303
      ret_url.query.return_type.should.equal 'url'
      ret_url.query.url.should.equal 'http://example.com/test'
      ret_url.query.text.should.equal 'text'
      ret_url.query.title.should.equal 'title'
      ret_url.query.target.should.equal '_blank'


  describe 'redirector', () ->
    it 'should be overridable', () ->
      test_res = null
      test_url = null

      lti.Extensions.Content.redirector = (res, outbound_url) ->
        test_res = res
        test_url = url.parse outbound_url, true

      @provider.ext_content.send_url @res, 'http://example.com/test'

      test_res.should.equal @res

      test_url.host.should.equal 'example.com'
      test_url.pathname.should.equal '/test'
      test_url.query.return_type.should.equal 'url'
      test_url.query.url.should.equal 'http://example.com/test'
