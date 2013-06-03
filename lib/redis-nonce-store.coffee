NonceStore = require './nonce-store'

# Five minutes
EXPIRE_IN_SEC = 5*60

class RedisNonceStore extends NonceStore

  constructor: (consumer_key, redisClient) ->
    @redis = redisClient

  isNew: (nonce, timestamp, next=()->)->

    if typeof nonce is 'undefined' or nonce is null or typeof nonce is 'function' or typeof timestamp is 'function' or typeof timestamp is 'undefined'
      return next new Error('Invalid parameters'), false

    if typeof timestamp is 'undefined' or timestamp is null
      return next new Error('Timestamp required'), false


    # Generate unix time in seconds
    currentTime = Math.round(Date.now()/1000)
    # Make sure this request is fresh (within the grace period)
    freshTimestamp = (currentTime - parseInt(timestamp,10)) <= EXPIRE_IN_SEC

    if not freshTimestamp
      return next new Error('Expired timestamp'), false

    # Pass all the parameter checks, now check to see if used
    client.get nonce, (err, seen) ->
      if seen
        return next new Error('Nonce already seen'), false
      # Dont have to wait for callback b/c it's a sync op
      @setUsed nonce, timestamp
      next null, true


  setUsed: (nonce, timestamp, next=()->)->
    @redis.set(nonce, timestamp);
    @redis.expire(nonce, EXPIRE_IN_SEC)
    next(null)


exports = module.exports = RedisNonceStore
