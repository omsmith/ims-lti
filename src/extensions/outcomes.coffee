crypto       = require 'crypto'
http         = require 'http'
https        = require 'https'
url          = require 'url'
uuid         = require 'node-uuid'


xml2js       = require 'xml2js'
xml_builder  = require 'xmlbuilder'

errors       = require '../errors'
HMAC_SHA1    = require '../hmac-sha1'
utils        = require '../utils'

REQUEST_REPLACE = 'replaceResult'
REQUEST_READ    = 'readResult'
REQUEST_DELETE  = 'deleteResult'


navigateXml = (xmlObject, path) ->
  for part in path.split '.'
    xmlObject = xmlObject?[part]?[0]

  return xmlObject


parseResponse = (body, callback) ->
  xml2js.parseString body, trim: true, (err, result) =>
    if err?
      callback new errors.OutcomeResponseError('The server responsed with an invalid XML document'), false
      return

    response  = result?.imsx_POXEnvelopeResponse
    code      = navigateXml response, 'imsx_POXHeader.imsx_POXResponseHeaderInfo.imsx_statusInfo.imsx_codeMajor'

    if code != 'success'
      msg = navigateXml response, 'imsx_POXHeader.imsx_POXResponseHeaderInfo.imsx_statusInfo.imsx_description'
      callback new errors.OutcomeResponseError(msg), false
    else
      callback null, true, response



class OutcomeDocument

  @replace: (source_did, payload, options) ->
    doc = new OutcomeDocument REQUEST_REPLACE, source_did, options

    if not payload?
      return doc

    doc.add_score(payload.score) if payload.score?
    doc.add_text(payload.text) if payload.text?
    doc.add_url(payload.url) if payload.url?

    return doc


  @read: (source_did, options) ->
    doc = new OutcomeDocument REQUEST_READ, source_did, options


  @delete: (source_did, options) ->
    doc = new OutcomeDocument REQUEST_DELETE, source_did, options


  constructor: (type, source_did, options) ->
    # unlike OutcomeService, OutcomeDocument defaults to support any result type
    @result_data_types = options?.result_data_types or true
    @language = options?.language or 'en'

    # Build and configure the document
    xmldec =
      version:     '1.0'
      encoding:    'UTF-8'

    @doc = xml_builder.create 'imsx_POXEnvelopeRequest', xmldec
    @doc.attribute 'xmlns', 'http://www.imsglobal.org/services/ltiv1p1/xsd/imsoms_v1p0'

    @head = @doc.ele('imsx_POXHeader').ele('imsx_POXRequestHeaderInfo')
    @body = @doc.ele('imsx_POXBody').ele(type + 'Request').ele('resultRecord')

    # Generate a unique identifier and apply the version to the header information
    @head.ele 'imsx_version', 'V1.0'
    @head.ele 'imsx_messageIdentifier', uuid.v1()

    # Apply the source DID to the body
    @body.ele('sourcedGUID').ele('sourcedId', source_did)


  add_score: (score) ->
    if (typeof score != 'number' or score < 0 or score > 1.0)
      throw new errors.ParameterError 'Score must be a floating point number >= 0 and <= 1'

    eScore = @_result_ele().ele('resultScore')
    eScore.ele('language', @language)
    eScore.ele('textString', score)


  add_text: (text) ->
    @_add_payload('text', text)

  add_url: (url) ->
    @_add_payload('url', url)


  finalize: () ->
    @doc.end(pretty: true)


  _result_ele: () ->
    @result or (@result = @body.ele('result'))


  _add_payload: (type, value) ->
    throw new errors.ExtensionError('Result data payload has already been set') if @has_payload
    throw new errors.ExtensionError('Result data type is not supported') if !@_supports_result_data(type)
    @_result_ele().ele('resultData').ele(type, value)
    @has_payload = true


  _supports_result_data: (type) ->
    if not @result_data_types || @result_data_types.length is 0
      return false

    if @result_data_types is true
      return true

    if not type?
      # Shouldn't be false?
      return true

    return @result_data_types.indexOf(type) != -1



class OutcomeService

  # deprecated
  REQUEST_REPLACE: REQUEST_REPLACE
  REQUEST_READ:    REQUEST_READ
  REQUEST_DELETE:  REQUEST_DELETE

  constructor: (options = {}) ->
    @consumer_key = options.consumer_key
    @consumer_secret = options.consumer_secret
    @service_url = options.service_url
    @source_did = options.source_did
    @result_data_types = options.result_data_types or []
    @signer = options.signer or (new HMAC_SHA1())
    @cert_authority = options.cert_authority or null
    @language = options.language or 'en'

    # Break apart the service url into the url fragments for use by OAuth signing, additionally prepare the OAuth
    # specific url that used exclusively in the signing process.
    parts = @service_url_parts = url.parse @service_url, true
    @service_url_oauth = parts.protocol + '//' + parts.host + parts.pathname


  send_replace_result: (score, callback) ->
    @_send_replace_result {score: score}, callback


  send_replace_result_with_text: (score, text, callback) ->
    @_send_replace_result {score: score, text: text}, callback


  send_replace_result_with_url: (score, url, callback) ->
    @_send_replace_result {score: score, url: url}, callback


  _send_replace_result: (payload, callback) ->
    try
      doc = OutcomeDocument.replace @source_did, payload, @
      @_send_request doc, callback
    catch err
      callback err, false


  send_read_result: (callback) ->
    doc = OutcomeDocument.read @source_did, @
    @_send_request doc, (err, result, xml) =>
      return callback(err, result) if err

      score = parseFloat navigateXml(xml, 'imsx_POXBody.readResultResponse.result.resultScore.textString'), 10

      if (isNaN(score))
        callback new errors.OutcomeResponseError('Invalid score response'), false
      else
        callback null, score


  send_delete_result: (callback) ->
    doc = OutcomeDocument.delete @source_did, @
    @_send_request doc, callback


  supports_result_data: (type) ->
    # deprecated
    return @result_data_types.length and (!type or @result_data_types.indexOf(type) != -1)


  _send_request: (doc, callback) ->
    xml     = doc.finalize()
    body    = ''
    is_ssl  = @service_url_parts.protocol == 'https:'

    options =
      hostname:  @service_url_parts.hostname
      path:      @service_url_parts.path
      method:    'POST'
      headers:   @_build_headers xml

    if @cert_authority and is_ssl
      options.ca = @cert_authority
    else
      options.agent = if is_ssl then https.globalAgent else http.globalAgent

    if @service_url_parts.port
      options.port = @service_url_parts.port

    # Make the request to the TC, verifying that the status code is valid and fetching the entire response body.
    req = (if is_ssl then https else http).request options, (res) =>
      res.setEncoding 'utf8'
      res.on 'data', (chunk) => body += chunk
      res.on 'end', () =>
        @_process_response body, callback

    req.on 'error', (err) =>
      callback err, false

    req.write xml
    req.end()


  _build_headers: (body) ->
    headers =
      oauth_version:           '1.0'
      oauth_nonce:             uuid.v4()
      oauth_timestamp:         Math.round Date.now() / 1000
      oauth_consumer_key:      @consumer_key
      oauth_body_hash:         crypto.createHash('sha1').update(body).digest('base64')
      oauth_signature_method:  'HMAC-SHA1'

    headers.oauth_signature = @signer.build_signature_raw @service_url_oauth, @service_url_parts, 'POST', headers, @consumer_secret

    Authorization:     'OAuth realm="",' + ("#{key}=\"#{utils.special_encode(val)}\"" for key, val of headers).join ','
    'Content-Type':    'application/xml'
    'Content-Length':  body.length


  _process_response: (body, callback) ->
    # deprecated
    parseResponse(body, callback)


exports.init = (provider) ->
  if (provider.body.lis_outcome_service_url and provider.body.lis_result_sourcedid)
    # The LTI 1.1 spec says that the language parameter is usually implied to be en, so the OutcomeService object
    # defaults to en until the spec updates and says there's other possible format options.
    accepted_vals = provider.body.ext_outcome_data_values_accepted
    provider.outcome_service = new OutcomeService(
      consumer_key: provider.consumer_key
      consumer_secret: provider.consumer_secret
      service_url: provider.body.lis_outcome_service_url,
      source_did: provider.body.lis_result_sourcedid,
      result_data_types: accepted_vals and accepted_vals.split(',') or []
      signer: provider.signer
    )
  else
    provider.outcome_service = false

exports.OutcomeDocument = OutcomeDocument
exports.OutcomeService = OutcomeService
exports.parseResponse = parseResponse
