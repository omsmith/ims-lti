# Export the main object
exports = module.exports =

  # Version of the library this is
  version: '0.0.0'

  # Provider and Consumer classes
  Provider: require './provider'
  Consumer: require './consumer'
  Errors:   require './errors'

  Stores:
    RedisStore:   require './redis-nonce-store'
    MemoryStore:  require './redis-nonce-store'
    NonceStore:   require './nonce-store'

  # Which version of the LTI standard are accepted
  supported_versions: [
    'LTI-1p0'
  ]
