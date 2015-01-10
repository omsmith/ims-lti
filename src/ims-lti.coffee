# Export the main object
exports = module.exports =

  # Version of the library this is
  version: '0.0.0'

  # Provider and Consumer classes
  Provider:        require './provider'
  Consumer:        require './consumer'
  OutcomeService:  require './outcome-service'
  Errors:          require './errors'

  Stores:
    RedisStore:   require './redis-nonce-store'
    MemoryStore:  require './memory-nonce-store'
    NonceStore:   require './nonce-store'

  Extensions: require './extensions'

  # Which version of the LTI standard are accepted
  supported_versions: [
    'LTI-1p0'
  ]
