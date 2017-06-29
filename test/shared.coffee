crypto       = require 'crypto'
http         = require 'http'
url          = require 'url'
uuid         = require 'uuid'
should       = require 'should'

xml2js       = require 'xml2js'
xml_builder  = require 'xmlbuilder'

hmac_sha1    = require '../src/hmac-sha1'


# Standard nonce tests
#
exports.shouldBehaveLikeNonce = (newStore=()->) =>

  before ()=>
    @store = newStore()

  after () =>
    if @store.redis
      @store.redis.flushdb()



  describe '.isNew', () =>
    it 'should exist', () =>
      should.exist(@store.isNew)

    it 'should return false if undefined passed', (done) =>
      store = newStore()
      store.isNew undefined, undefined, (err, valid)->
        err.should.not.equal null
        valid.should.equal false
        done()

    it 'should return false if no nonce but timestamp', (done) ->
      store = newStore()
      store.isNew undefined, Math.round(Date.now()/1000), (err, valid)->
        err.should.not.equal null
        valid.should.equal false
        done()

    it 'should return false if nonce but no timestamp', (done) ->
      store = newStore()
      store.isNew '1', undefined, (err, valid)->
        err.should.not.equal null
        valid.should.equal false
        done()

    it 'should return true for new nonces', (done) =>
      store = newStore()
      now = Math.round(Date.now()/1000)

      nonce_one = 'true-for-new-1-'+Math.random()*1000
      nonce_two = 'true-for-new-2-'+Math.random()*1000
      store.isNew nonce_one, now, (err, valid)->
        should.not.exist err
        valid.should.equal true

        store.isNew nonce_two, now+1, (err, valid) ->
          should.not.exist err
          valid.should.equal true
          done()

    it 'should return false for used nonces', (done) =>
      store = newStore()
      now = Math.round(Date.now()/1000)

      nonce = 'should-return-false-for-used-'+Math.random()*1000

      store.isNew nonce, now, (err, valid)->
        should.not.exist err
        valid.should.equal true

        store.isNew nonce, now+1, (err, valid) ->
          should.exist err
          valid.should.equal false
          done()


    it 'should return true for time-relivant nonces', (done) =>
      store = newStore()

      now = Math.round(Date.now()/1000)
      future = now+1*60
      past_minute = now - 1*60
      past_two_minutes = now - 2*60

      first_test = () ->
        store.isNew 'tr-00', now, (err, valid) ->
          should.not.exist err
          valid.should.equal true
          second_test()
      second_test = () ->
        store.isNew 'tr-11', future, (err, valid) ->
          should.not.exist err
          valid.should.equal true
          third_test()
      third_test = () ->
        store.isNew 'tr-01', past_minute, (err, valid) ->
          should.not.exist err
          valid.should.equal true
          fourth_test()
      fourth_test = () ->
        store.isNew 'tr-02', past_two_minutes, (err, valid) ->
          should.not.exist err
          valid.should.equal true
          done()

      first_test()

    it 'should return false for expired nonces', (done) =>
      store = newStore()

      now = Math.round(Date.now()/1000)
      five_and_one_sec_old = now-5*60-1
      hour_old = now-60*60

      first_test = () ->
        store.isNew '00', five_and_one_sec_old, (err, valid) ->
          should.exist err
          valid.should.equal false
          second_test()
      second_test = () ->
        store.isNew '11', hour_old, (err, valid) ->
          should.exist err
          valid.should.equal false
          done()

      first_test()

  describe '.setUsed', () =>
    it 'should exist', () =>
      should.exist(@store.setUsed)

    it 'should set nonces to used', (done) =>
      store = newStore()
      now = Math.round(Date.now()/1000)
      store.setUsed '11', now, () ->
        store.isNew '11', now+1, (err, valid) ->
          should.exist err
          valid.should.equal false
          done()



# Creates a webserver that can respond to the outcomes service
#
exports.outcomesWebServer = () =>
  buildXmlDocument = (type = 'Request') =>
    # Build and configure the document
    xmldec =
      version:     '1.0'
      encoding:    'UTF-8'

    doc = xml_builder.create 'imsx_POXEnvelopeResponse', xmldec
    doc.attribute 'xmlns', 'http://www.imsglobal.org/services/ltiv1p1/xsd/imsoms_v1p0'

    return doc


  cleanupValue = (value) =>
    decodeURIComponent value.substr(1, value.length - 2)


  verifySignature = (req, body) =>
    params       = {}
    signer       = new hmac_sha1
    service_url  = 'http://127.0.0.1:1337/service/url'

    return params if typeof req.headers.authorization != 'string'

    for param in req.headers.authorization.split ','
      parts = param.split '='
      params[decodeURIComponent parts[0]] = cleanupValue parts[1]

    delete params['OAuth realm']

    body_signature = crypto.createHash('sha1').update(body).digest('base64')
    req_signature  = signer.build_signature_raw service_url, url.parse(service_url), 'POST', params, 'secret'

    return body_signature == params.oauth_body_hash and req_signature == params.oauth_signature


  notFoundHandler = (req, res) =>
    res.writeHead 404, 'Content-Type': 'text/html'
    res.end 'Page not found'


  outcomeTypeNotFoundHandler = (res, type) =>
    res.writeHead 404, 'Content-Type': 'application/xml'

    doc   = buildXmlDocument()
    head  = doc.ele('imsx_POXHeader').ele('imsx_POXResponseHeaderInfo')

    doc.ele 'imsx_POXBody'

    head.ele 'imsx_version', 'V1.0'
    head.ele 'imsx_messageIdentifier', uuid.v4()

    sub_head = head.ele 'imsx_statusInfo'
    sub_head.ele 'imsx_codeMajor', 'unsupported'
    sub_head.ele 'imsx_severity', 'status'
    sub_head.ele 'imsx_description', "#{type} is not supported"
    sub_head.ele 'imsx_messageRefIdentifier', uuid.v4()
    sub_head.ele 'imsx_operationRefIdentifier', type

    res.end doc.end() + '\n'


  invalidSignatureError = (res) =>
    res.writeHead 403, 'Content-Type': 'application/xml'

    doc   = buildXmlDocument()
    head  = doc.ele('imsx_POXHeader').ele('imsx_POXResponseHeaderInfo')

    doc.ele 'imsx_POXBody'

    head.ele 'imsx_version', 'V1.0'
    head.ele 'imsx_messageIdentifier', uuid.v4()

    sub_head = head.ele 'imsx_statusInfo'
    sub_head.ele 'imsx_codeMajor', 'failure'
    sub_head.ele 'imsx_severity', 'signature'
    sub_head.ele 'imsx_description', 'The signature provided is not valid'
    sub_head.ele 'imsx_messageRefIdentifier', uuid.v4()
    sub_head.ele 'imsx_operationRefIdentifier', 'signature'

    res.end doc.end() + '\n'


  invalidScoreError = (res) =>
    res.writeHead 403, 'Content-Type': 'application/xml'

    doc   = buildXmlDocument()
    head  = doc.ele('imsx_POXHeader').ele('imsx_POXResponseHeaderInfo')

    doc.ele 'imsx_POXBody'

    head.ele 'imsx_version', 'V1.0'
    head.ele 'imsx_messageIdentifier', uuid.v4()

    sub_head = head.ele 'imsx_statusInfo'
    sub_head.ele 'imsx_codeMajor', 'failure'
    sub_head.ele 'imsx_severity', 'score'
    sub_head.ele 'imsx_description', 'The score provided is not valid'
    sub_head.ele 'imsx_messageRefIdentifier', uuid.v4()
    sub_head.ele 'imsx_operationRefIdentifier', 'score'

    res.end doc.end() + '\n'


  validScoreResponse = (res, id, score) =>
    res.writeHead 200, 'Content-Type': 'application/xml'

    doc   = buildXmlDocument()
    head  = doc.ele('imsx_POXHeader').ele('imsx_POXResponseHeaderInfo')

    doc.ele('imsx_POXBody').ele('replaceResultResponse')

    head.ele 'imsx_version', 'V1.0'
    head.ele 'imsx_messageIdentifier', uuid.v4()

    sub_head = head.ele 'imsx_statusInfo'
    sub_head.ele 'imsx_codeMajor', 'success'
    sub_head.ele 'imsx_severity', 'status'
    sub_head.ele 'imsx_description', "The score for #{id} is now #{score}"
    sub_head.ele 'imsx_messageRefIdentifier', uuid.v4()
    sub_head.ele 'imsx_operationRefIdentifier', 'replaceResult'

    res.end doc.end() + '\n'


  validReadResponse = (res) =>
    res.writeHead 200, 'Content-Type': 'application/xml'

    doc   = buildXmlDocument()
    head  = doc.ele('imsx_POXHeader').ele('imsx_POXResponseHeaderInfo')

    result = doc.ele('imsx_POXBody').ele('readResultResponse').ele('result').ele('resultScore')
    result.ele 'language', 'en'
    result.ele 'textString', '.5'

    head.ele 'imsx_version', 'V1.0'
    head.ele 'imsx_messageIdentifier', uuid.v4()

    sub_head = head.ele 'imsx_statusInfo'
    sub_head.ele 'imsx_codeMajor', 'success'
    sub_head.ele 'imsx_severity', 'status'
    sub_head.ele 'imsx_description', 'Result read'
    sub_head.ele 'imsx_messageRefIdentifier', uuid.v4()
    sub_head.ele 'imsx_operationRefIdentifier', 'readResult'

    res.end doc.end() + '\n'


  validDeleteResponse = (res) =>
    res.writeHead 200, 'Content-Type': 'application/xml'

    doc   = buildXmlDocument()
    head  = doc.ele('imsx_POXHeader').ele('imsx_POXResponseHeaderInfo')

    doc.ele('imsx_POXBody').ele('deleteResultResponse')

    head.ele 'imsx_version', 'V1.0'
    head.ele 'imsx_messageIdentifier', uuid.v4()

    sub_head = head.ele 'imsx_statusInfo'
    sub_head.ele 'imsx_codeMajor', 'success'
    sub_head.ele 'imsx_severity', 'status'
    sub_head.ele 'imsx_description', 'Result deleted'
    sub_head.ele 'imsx_messageRefIdentifier', uuid.v4()
    sub_head.ele 'imsx_operationRefIdentifier', 'deleteResult'

    res.end doc.end() + '\n'

  verifyDoc = (doc) =>
    doc.should.be.an.Object;
    doc.should.have.property('sourcedGUID').with.lengthOf(1);
    doc.sourcedGUID[0].should.be.an.Object;
    doc.sourcedGUID[0].should.have.property('sourcedId').with.lengthOf(1);
    doc.sourcedGUID[0].sourcedId[0].should.be.a.String

  outcomesHandler = (req, res) =>
    headers  = 'Content-Type': 'application/xml'
    body     = ''

    req.on 'data', (buffer) =>
      body += buffer.toString 'utf8'

    req.on 'end', () =>
      if (!verifySignature(req, body))
        return invalidSignatureError(res)

      xml2js.parseString body, trim: true, (err, result) =>
        result_body = result?.imsx_POXEnvelopeRequest?.imsx_POXBody?[0]
        result_type = Object.keys(result_body or {})[0]

        switch result_type
          when 'replaceResultRequest'
            verifyDoc result_body?.replaceResultRequest?[0].resultRecord[0]

            # As ugly as this may be this is one of the most effective XML parsers for node... yeah...
            score = parseFloat result_body?.replaceResultRequest?[0].resultRecord?[0].result?[0].resultScore?[0].textString?[0], 10

            if (score < 0 or score > 1)
              return invalidScoreError res
            else
              return validScoreResponse res, null, score

          when 'readResultRequest'
            verifyDoc result_body?.readResultRequest?[0].resultRecord[0]

            return validReadResponse res

          when 'deleteResultRequest'
            verifyDoc result_body?.deleteResultRequest?[0].resultRecord[0]

            return validDeleteResponse res

          else
            return outcomeTypeNotFoundHandler(res, result_type or 'undefinedRequest')


  http.createServer (req, res) =>
    path     = url.parse req.url
    handler  = if path.pathname == '/service/url' then outcomesHandler else notFoundHandler

    handler req, res

