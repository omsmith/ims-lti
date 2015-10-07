url    = require 'url'

errors = require '../errors'

FILE_RETURN_TYPE           = 'file'
IFRAME_RETURN_TYPE         = 'iframe'
IMAGE_URL_RETURN_TYPE      = 'image_url'
LTI_LAUNCH_URL_RETURN_TYPE = 'lti_launch_url'
OEMBED_RETURN_TYPE         = 'oembed'
URL_RETURN_TYPE            = 'url'


parse_url = (raw_url) ->
  return_url = url.parse(raw_url, true)
  delete return_url.path
  return_url

optional_url_property_setter = (return_url) ->
  return (property, value) ->
    if typeof value isnt 'undefined'
      return_url.query[property] = value



class ContentExtension
  constructor: (params) ->
    @return_types    = params.ext_content_return_types.split(',')
    # According to the spec if the ext_content_return_url is not present launch_presentation_return_url is the fallback.
    @return_url      = params.ext_content_return_url or params.launch_presentation_return_url
    @file_extensions = (params.ext_content_file_extensions and params.ext_content_file_extensions.split(',')) or []


  has_return_type: (return_type) ->
    @return_types.indexOf(return_type) != -1


  has_file_extension: (extension) ->
    @file_extensions.indexOf(extension) != -1


  send_file: (res, file_url, text, content_type) ->
    @_validate_return_type(FILE_RETURN_TYPE)

    return_url    = parse_url(@return_url, true)
    set_if_exists = optional_url_property_setter(return_url)

    return_url.query.return_type = FILE_RETURN_TYPE
    return_url.query.url         = file_url
    return_url.query.text        = text

    set_if_exists('content_type', content_type)

    exports.redirector(res, url.format(return_url))


  send_iframe: (res, iframe_url, title, width, height) ->
    @_validate_return_type(IFRAME_RETURN_TYPE)

    return_url    = parse_url(@return_url, true)
    set_if_exists = optional_url_property_setter(return_url)

    return_url.query.return_type = IFRAME_RETURN_TYPE
    return_url.query.url         = iframe_url

    set_if_exists("title", title)
    set_if_exists("width", width)
    set_if_exists("height", height)

    exports.redirector(res, url.format(return_url))


  send_image_url: (res, image_url, text, width, height) ->
    @_validate_return_type(IMAGE_URL_RETURN_TYPE)

    return_url    = parse_url(@return_url, true)
    set_if_exists = optional_url_property_setter(return_url)

    return_url.query.return_type = IMAGE_URL_RETURN_TYPE
    return_url.query.url         = image_url

    set_if_exists("text", text)
    set_if_exists("width", width)
    set_if_exists("height", height)

    exports.redirector(res, url.format(return_url))


  send_lti_launch_url: (res, launch_url, title, text) ->
    @_validate_return_type(LTI_LAUNCH_URL_RETURN_TYPE)

    return_url    = parse_url(@return_url, true)
    set_if_exists = optional_url_property_setter(return_url)

    return_url.query.return_type = LTI_LAUNCH_URL_RETURN_TYPE
    return_url.query.url         = launch_url

    set_if_exists("title", title)
    set_if_exists("text", text)

    exports.redirector(res, url.format(return_url))


  send_oembed: (res, oembed_url, endpoint) ->
    @_validate_return_type(OEMBED_RETURN_TYPE)

    return_url    = parse_url(@return_url, true)
    set_if_exists = optional_url_property_setter(return_url)

    return_url.query.return_type = OEMBED_RETURN_TYPE
    return_url.query.url         = oembed_url

    set_if_exists("endpoint", endpoint)

    exports.redirector(res, url.format(return_url))


  send_url: (res, hyperlink, text, title, target) ->
    @_validate_return_type(URL_RETURN_TYPE)

    return_url    = parse_url(@return_url, true)
    set_if_exists = optional_url_property_setter(return_url)

    return_url.query.return_type = URL_RETURN_TYPE
    return_url.query.url         = hyperlink

    set_if_exists('text', text)
    set_if_exists('title', title)
    set_if_exists('target', target)

    exports.redirector(res, url.format(return_url))


  _validate_return_type: (return_type) ->
    if @has_return_type(return_type) is false
      throw new errors.ExtensionError('Invalid return type, valid options are ' + @return_types.join(', '))



exports.init = (provider) ->
  # The extension is defined to exist if the ext_content_return_types parameter is present.
  if provider.body.ext_content_return_types
    provider.ext_content = new ContentExtension(provider.body)
  else
    provider.ext_content = false


# The default redirector is set to be compatible with Express and can be easily overridden by accessing the ims-lti
# module and setting lti.Extensions.Content.redirector to a custom function.
exports.redirector = (res, url) ->
  res.redirect(303, url)
