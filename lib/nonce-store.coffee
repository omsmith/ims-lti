class NonceStore

  isNonceStore: () -> true

  isNew:   ()=>
    for i, arg of arguments
      return arg new Error("NOT IMPLEMENTED"), false if typeof arg is 'function'

  setUsed: ()=>
    for i, arg of arguments
      return arg new Error("NOT IMPLEMENTED"), false if typeof arg is 'function'


exports = module.exports = NonceStore