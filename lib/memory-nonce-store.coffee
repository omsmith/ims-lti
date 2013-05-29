NonceStore = require './nonce-store'

class MemoryNonceStore extends NonceStore

  constructor: (consumer_key) ->
    @used = []

  isNew:   (nonce="not-set", timestamp)->
    nonce
    notInArray = @used.indexOf(nonce) is -1
    @setUsed(nonce, timestamp) if notInArray
    return notInArray

  setUsed: (nonce, timestamp)->
    @used.push(nonce)


exports = module.exports = MemoryNonceStore