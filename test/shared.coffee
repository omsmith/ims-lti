should            = require 'should'

  # Standard nonce tests
  #
exports.shouldBehaveLikeNonce = (newStore) =>

  before ()=>
    @store = newStore()



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
      store.isNew 'first-nonce', now, (err, valid)->
        should.not.exist err
        valid.should.equal true

        store.isNew 'second-nonce', now+1, (err, valid) ->
          should.not.exist err
          valid.should.equal true
          done()

    it 'should return false for used nonces', (done) =>
      store = newStore()
      now = Math.round(Date.now()/1000)
      store.isNew 'first-nonce', now, (err, valid)->
        should.not.exist err
        valid.should.equal true

        store.isNew 'second-nonce', now+1, (err, valid) ->
          should.not.exist err
          valid.should.equal true
          done()


    it 'should return true for time-relivant nonces', (done) =>
      store = newStore()

      now = Math.round(Date.now()/1000)
      future = now+1*60
      past_minute = now - 1*60
      past_two_minutes = now - 2*60

      first_test = () ->
        store.isNew '00', now, (err, valid) ->
          should.not.exist err
          valid.should.equal true
          second_test()
      second_test = () ->
        store.isNew '11', future, (err, valid) ->
          should.not.exist err
          valid.should.equal true
          third_test()
      third_test = () ->
        store.isNew '01', past_minute, (err, valid) ->
          should.not.exist err
          valid.should.equal true
          fourth_test()
      fourth_test = () ->
        store.isNew '02', past_two_minutes, (err, valid) ->
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