# Special encode is our encoding method that implements
#  the encoding of characters not defaulted by encodeURI
#
#  Specifically ' and !
#
# Returns the encoded string
exports.special_encode = (string) ->
  encodeURIComponent(string).replace(/[!'()]/g, escape).replace(/\*/g, '%2A')
