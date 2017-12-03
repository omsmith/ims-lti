/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const url = require('url');
const should = require('should');
const lti = require('../');

describe('LTI.Extensions.Content', function() {
  beforeEach(function() {
    this.provider = new lti.Provider('key', 'secret');

    const req = {
      body: {
        ext_content_return_types: 'file,iframe,image_url,lti_launch_url,oembed,url',
        ext_content_return_url: 'http://example.com/test',
        ext_content_file_extensions: 'txt,jpg'
      }
    };

    this.res = {
      status: null,
      url: null,
      redirect(status, url1) {
        this.status = status;
        this.url = url1;
      }
    };

    return this.provider.parse_request(req);
  });


  describe('constructor', function() {
    it('should initialize an object if ext_content_return_types is set', function() {
      return this.provider.ext_content.should.exist;
    });

    return it('should be false if ext_content_return_types is missing', function() {
      const provider = new lti.Provider('key', 'secret');
      provider.parse_request({ body: {} });
      return provider.ext_content.should.equal(false);
    });
  });


  describe('_validate_return_type', () =>
    it('should throw an exception if the type does not exist for the provider', function() {
      const fn = () => {
        return this.provider.ext_content._validate_return_type('invalid');
      };

      return fn.should.throw();
    })
  );


  describe('has_return_type', () =>
    it('should be able to check if a return type is set', function() {
      this.provider.ext_content.has_return_type('file').should.equal(true);
      this.provider.ext_content.has_return_type('iframe').should.equal(true);
      return this.provider.ext_content.has_return_type('fail').should.equal(false);
    })
  );


  describe('has_file_extension', () =>
    it('should be able to check if a file extension is set', function() {
      this.provider.ext_content.has_file_extension('txt').should.equal(true);
      this.provider.ext_content.has_file_extension('jpg').should.equal(true);
      return this.provider.ext_content.has_file_extension('rar').should.equal(false);
    })
  );


  describe('send_file', function() {
    it('should generate a query string for the base params and exclude optional ones', function() {
      this.provider.ext_content.send_file(this.res, 'http://example.com/myfile.txt', 'myfile.txt');

      const ret_url = url.parse(this.res.url, true);

      this.res.status.should.equal(303);
      ret_url.query.return_type.should.equal('file');
      ret_url.query.url.should.equal('http://example.com/myfile.txt');
      ret_url.query.text.should.equal('myfile.txt');
      return should(ret_url.query).not.have.property('content_type');
    });

    return it('should generate a query string for the optional parameters', function() {
      this.provider.ext_content.send_file(this.res, 'http://example.com/myfile.txt', 'myfile.txt', 'text/plain');

      const ret_url = url.parse(this.res.url, true);

      this.res.status.should.equal(303);
      ret_url.query.return_type.should.equal('file');
      ret_url.query.url.should.equal('http://example.com/myfile.txt');
      ret_url.query.text.should.equal('myfile.txt');
      return ret_url.query.content_type.should.equal('text/plain');
    });
  });


  describe('send_iframe', function() {
    it('should generate a query string for the base params and exclude optional ones', function() {
      this.provider.ext_content.send_iframe(this.res, 'http://example.com/myfile.txt');

      const ret_url = url.parse(this.res.url, true);

      this.res.status.should.equal(303);
      ret_url.query.return_type.should.equal('iframe');
      ret_url.query.url.should.equal('http://example.com/myfile.txt');
      should(ret_url.query).not.have.property('title');
      should(ret_url.query).not.have.property('width');
      return should(ret_url.query).not.have.property('height');
    });

    return it('should generate a query string for the optional parameters', function() {
      this.provider.ext_content.send_iframe(this.res, 'http://example.com/myfile.txt', 'title', 800, 600);

      const ret_url = url.parse(this.res.url, true);

      this.res.status.should.equal(303);
      ret_url.query.return_type.should.equal('iframe');
      ret_url.query.url.should.equal('http://example.com/myfile.txt');
      ret_url.query.title.should.equal('title');
      ret_url.query.width.should.equal('800');
      return ret_url.query.height.should.equal('600');
    });
  });


  describe('send_image_url', function() {
    it('should generate a query string for the base params and exclude optional ones', function() {
      this.provider.ext_content.send_image_url(this.res, 'http://example.com/myfile.jpg');

      const ret_url = url.parse(this.res.url, true);

      this.res.status.should.equal(303);
      ret_url.query.return_type.should.equal('image_url');
      ret_url.query.url.should.equal('http://example.com/myfile.jpg');
      should(ret_url.query).not.have.property('text');
      should(ret_url.query).not.have.property('width');
      return should(ret_url.query).not.have.property('height');
    });

    return it('should generate a query string for the optional parameters', function() {
      this.provider.ext_content.send_image_url(this.res, 'http://example.com/myfile.jpg', 'alt', 800, 600);

      const ret_url = url.parse(this.res.url, true);

      this.res.status.should.equal(303);
      ret_url.query.return_type.should.equal('image_url');
      ret_url.query.url.should.equal('http://example.com/myfile.jpg');
      ret_url.query.text.should.equal('alt');
      ret_url.query.width.should.equal('800');
      return ret_url.query.height.should.equal('600');
    });
  });


  describe('send_lti_launch_url', function() {
    it('should generate a query string for the base params and exclude optional ones', function() {
      this.provider.ext_content.send_lti_launch_url(this.res, 'http://example.com/test');

      const ret_url = url.parse(this.res.url, true);

      this.res.status.should.equal(303);
      ret_url.query.return_type.should.equal('lti_launch_url');
      ret_url.query.url.should.equal('http://example.com/test');
      should(ret_url.query).not.have.property('title');
      return should(ret_url.query).not.have.property('text');
    });

    return it('should generate a query string for the optional parameters', function() {
      this.provider.ext_content.send_lti_launch_url(this.res, 'http://example.com/test', 'title', 'text');

      const ret_url = url.parse(this.res.url, true);

      this.res.status.should.equal(303);
      ret_url.query.return_type.should.equal('lti_launch_url');
      ret_url.query.url.should.equal('http://example.com/test');
      ret_url.query.title.should.equal('title');
      return ret_url.query.text.should.equal('text');
    });
  });


  describe('send_oembed', function() {
    it('should generate a query string for the base params and exclude optional ones', function() {
      this.provider.ext_content.send_oembed(this.res, 'http://example.com/test');

      const ret_url = url.parse(this.res.url, true);

      this.res.status.should.equal(303);
      ret_url.query.return_type.should.equal('oembed');
      ret_url.query.url.should.equal('http://example.com/test');
      return should(ret_url.query).not.have.property('endpoint');
    });

    return it('should generate a query string for the optional parameters', function() {
      this.provider.ext_content.send_oembed(this.res, 'http://example.com/test', 'http://example.com/test2');

      const ret_url = url.parse(this.res.url, true);

      this.res.status.should.equal(303);
      ret_url.query.return_type.should.equal('oembed');
      ret_url.query.url.should.equal('http://example.com/test');
      return ret_url.query.endpoint.should.equal('http://example.com/test2');
    });
  });


  describe('send_url', function() {
    it('should generate a query string for the base params and exclude optional ones', function() {
      this.provider.ext_content.send_url(this.res, 'http://example.com/test');

      const ret_url = url.parse(this.res.url, true);

      this.res.status.should.equal(303);
      ret_url.query.return_type.should.equal('url');
      ret_url.query.url.should.equal('http://example.com/test');
      should(ret_url.query).not.have.property('text');
      should(ret_url.query).not.have.property('title');
      return should(ret_url.query).not.have.property('target');
    });

    return it('should generate a query string for the optional parameters', function() {
      this.provider.ext_content.send_url(this.res, 'http://example.com/test', 'text', 'title', '_blank');

      const ret_url = url.parse(this.res.url, true);

      this.res.status.should.equal(303);
      ret_url.query.return_type.should.equal('url');
      ret_url.query.url.should.equal('http://example.com/test');
      ret_url.query.text.should.equal('text');
      ret_url.query.title.should.equal('title');
      return ret_url.query.target.should.equal('_blank');
    });
  });


  return describe('redirector', () =>
    it('should be overridable', function() {
      let test_res = null;
      let test_url = null;

      lti.Extensions.Content.redirector = function(res, outbound_url) {
        test_res = res;
        return test_url = url.parse(outbound_url, true);
      };

      this.provider.ext_content.send_url(this.res, 'http://example.com/test');

      test_res.should.equal(this.res);

      test_url.host.should.equal('example.com');
      test_url.pathname.should.equal('/test');
      test_url.query.return_type.should.equal('url');
      return test_url.query.url.should.equal('http://example.com/test');
    })
  );
});
