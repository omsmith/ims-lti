/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
// Special encode is our encoding method that implements
//  the encoding of characters not defaulted by encodeURI
//
//  Specifically ' and !
//
// Returns the encoded string
exports.special_encode = string => encodeURIComponent(string).replace(/[!'()]/g, escape).replace(/\*/g, '%2A');
