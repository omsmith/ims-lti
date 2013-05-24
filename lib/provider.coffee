class Provider

  constructor: (consumer_key, consumer_secret, params) ->

    if typeof consumer_key is 'undefined' or consumer_key is null
      throw new Error 'Must specify consumer_key'

    if typeof consumer_secret is 'undefined' or consumer_secret is null
      throw new Error 'Must specify consumer_secret'

    @consumer_key     = consumer_key
    @consumer_secret  = consumer_secret
    @config           = params


  # Verify OAuth signature by passing the request object
  # Returns true/false if is valid
  #
  # Sets up request variables for easier access down the line
  valid_request: (req) ->
    return true


exports = module.exports = Provider
