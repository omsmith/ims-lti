fs          = require 'fs'
https       = require 'https'
urlUtil     = require 'url'
request     = require 'request'
querystring = require 'querystring'

# Export the main object
exports = module.exports =
  Provider: require './provider'
  Consumer: require './consumer'
  version: '0.0.0'