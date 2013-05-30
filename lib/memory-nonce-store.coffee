NonceStore = require './nonce-store'

# Five minutes
EXPIRE_IN_SEC = 5*60

class MemoryNonceStore extends NonceStore

  constructor: (consumer_key) ->
    @used = []

  isNew: (nonce, timestamp, next=()->)->

    if typeof nonce is 'undefined' or nonce is null or typeof nonce is 'function' or typeof timestamp is 'function' or typeof timestamp is 'undefined'
      return next new Error('Invalid parameters'), false

    firstTimeSeen = @used.indexOf(nonce) is -1

    if not firstTimeSeen
      return next new Error('Nonce already seen'), false

    @setUsed nonce, timestamp, (err) ->
      if typeof timestamp isnt 'undefined' and timestamp isnt null
        # Generate unix time in seconds
        currentTime = Math.round(Date.now()/1000)
        # Make sure this request is fresh (within the grace period)
        timestampIsFresh = (currentTime - parseInt(timestamp,10)) <= EXPIRE_IN_SEC

        if timestampIsFresh
          next null, true
        else
          next new Error('Expired timestamp'), false
      else
        next new Error('Timestamp required'), false

  setUsed: (nonce, timestamp, next=()->)->
    @used.push(nonce)
    next(null)


exports = module.exports = MemoryNonceStore