NonceStore = require './nonce-store'

# Five minutes
EXPIRE_IN_SEC = 5*60

class MemoryNonceStore extends NonceStore

  constructor: (consumer_key) ->
    @used = []

  isNew:   (nonce, timestamp)->

    return false if typeof nonce is 'undefined' or nonce is null

    notInArray = @used.indexOf(nonce) is -1
    @setUsed(nonce, timestamp)

    if typeof timestamp isnt 'undefined' and timestamp isnt null
      # Generate unix time in seconds
      currentTime = Math.round(Date.now()/1000)
      # Make sure this request is fresh (within the grace period)
      timestampIsFresh = (currentTime - parseInt(timestamp,10)) <= EXPIRE_IN_SEC
    else
      timestampIsFresh = true

    return notInArray and timestampIsFresh

  setUsed: (nonce, timestamp)->
    @used.push(nonce)


exports = module.exports = MemoryNonceStore