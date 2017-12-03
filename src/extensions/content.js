/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const url    = require('url');

const errors = require('../errors');

const FILE_RETURN_TYPE           = 'file';
const IFRAME_RETURN_TYPE         = 'iframe';
const IMAGE_URL_RETURN_TYPE      = 'image_url';
const LTI_LAUNCH_URL_RETURN_TYPE = 'lti_launch_url';
const OEMBED_RETURN_TYPE         = 'oembed';
const URL_RETURN_TYPE            = 'url';


const parse_url = function(raw_url) {
  const return_url = url.parse(raw_url, true);
  delete return_url.path;
  return return_url;
};

const optional_url_property_setter = return_url =>
  function(property, value) {
    if (typeof value !== 'undefined') {
      return return_url.query[property] = value;
    }
  }
;



class ContentExtension {
  constructor(params) {
    this.return_types    = params.ext_content_return_types.split(',');
    // According to the spec if the ext_content_return_url is not present launch_presentation_return_url is the fallback.
    this.return_url      = params.ext_content_return_url || params.launch_presentation_return_url;
    this.file_extensions = (params.ext_content_file_extensions && params.ext_content_file_extensions.split(',')) || [];
  }


  has_return_type(return_type) {
    return this.return_types.indexOf(return_type) !== -1;
  }


  has_file_extension(extension) {
    return this.file_extensions.indexOf(extension) !== -1;
  }


  send_file(res, file_url, text, content_type) {
    this._validate_return_type(FILE_RETURN_TYPE);

    const return_url    = parse_url(this.return_url, true);
    const set_if_exists = optional_url_property_setter(return_url);

    return_url.query.return_type = FILE_RETURN_TYPE;
    return_url.query.url         = file_url;
    return_url.query.text        = text;

    set_if_exists('content_type', content_type);

    return exports.redirector(res, url.format(return_url));
  }


  send_iframe(res, iframe_url, title, width, height) {
    this._validate_return_type(IFRAME_RETURN_TYPE);

    const return_url    = parse_url(this.return_url, true);
    const set_if_exists = optional_url_property_setter(return_url);

    return_url.query.return_type = IFRAME_RETURN_TYPE;
    return_url.query.url         = iframe_url;

    set_if_exists("title", title);
    set_if_exists("width", width);
    set_if_exists("height", height);

    return exports.redirector(res, url.format(return_url));
  }


  send_image_url(res, image_url, text, width, height) {
    this._validate_return_type(IMAGE_URL_RETURN_TYPE);

    const return_url    = parse_url(this.return_url, true);
    const set_if_exists = optional_url_property_setter(return_url);

    return_url.query.return_type = IMAGE_URL_RETURN_TYPE;
    return_url.query.url         = image_url;

    set_if_exists("text", text);
    set_if_exists("width", width);
    set_if_exists("height", height);

    return exports.redirector(res, url.format(return_url));
  }


  send_lti_launch_url(res, launch_url, title, text) {
    this._validate_return_type(LTI_LAUNCH_URL_RETURN_TYPE);

    const return_url    = parse_url(this.return_url, true);
    const set_if_exists = optional_url_property_setter(return_url);

    return_url.query.return_type = LTI_LAUNCH_URL_RETURN_TYPE;
    return_url.query.url         = launch_url;

    set_if_exists("title", title);
    set_if_exists("text", text);

    return exports.redirector(res, url.format(return_url));
  }


  send_oembed(res, oembed_url, endpoint) {
    this._validate_return_type(OEMBED_RETURN_TYPE);

    const return_url    = parse_url(this.return_url, true);
    const set_if_exists = optional_url_property_setter(return_url);

    return_url.query.return_type = OEMBED_RETURN_TYPE;
    return_url.query.url         = oembed_url;

    set_if_exists("endpoint", endpoint);

    return exports.redirector(res, url.format(return_url));
  }


  send_url(res, hyperlink, text, title, target) {
    this._validate_return_type(URL_RETURN_TYPE);

    const return_url    = parse_url(this.return_url, true);
    const set_if_exists = optional_url_property_setter(return_url);

    return_url.query.return_type = URL_RETURN_TYPE;
    return_url.query.url         = hyperlink;

    set_if_exists('text', text);
    set_if_exists('title', title);
    set_if_exists('target', target);

    return exports.redirector(res, url.format(return_url));
  }


  _validate_return_type(return_type) {
    if (this.has_return_type(return_type) === false) {
      throw new errors.ExtensionError(`Invalid return type, valid options are ${this.return_types.join(', ')}`);
    }
  }
}



exports.init = function(provider) {
  // The extension is defined to exist if the ext_content_return_types parameter is present.
  if (provider.body.ext_content_return_types) {
    return provider.ext_content = new ContentExtension(provider.body);
  } else {
    return provider.ext_content = false;
  }
};


// The default redirector is set to be compatible with Express and can be easily overridden by accessing the ims-lti
// module and setting lti.Extensions.Content.redirector to a custom function.
exports.redirector = (res, url) => res.redirect(303, url);
