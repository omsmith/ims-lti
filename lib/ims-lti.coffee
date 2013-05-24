fs          = require 'fs'
https       = require 'https'
urlUtil     = require 'url'
request     = require 'request'
querystring = require 'querystring'

# Export the main object
exports = module.exports =

  # Version of the library this is
  version: '0.0.0'

  # Provider and Consumer classes
  Provider: require './provider'
  Consumer: require './consumer'

  # Which version of the LTI standard are accepted
  supported_versions: [
    '1.0'
    '1.1'
  ]