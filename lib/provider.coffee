class Provider

  constructor: (consumer_key, consumer_secret, params) ->
    @consumer_key     = consumer_key
    @consumer_secret  = consumer_secret
    @config           = params



  # Verify OAuth signature by passing the request object
  # Returns true/false if is valid
  #
  # Sets up request variables for easier access down the line
  valid_request: (req) ->
    return true


exports = Provider