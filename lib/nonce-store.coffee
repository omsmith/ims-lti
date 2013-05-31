class NonceStore

  isNonceStore: () -> true

  isNew:   ()=>
    console.error 'NONCE isNew NOT IMPLEMENTED'
    for i, arg of arguments
      return arg new Error("NOT IMPLEMENTED"), false if typeof arg is 'function'

  setUsed: ()=>
    console.error 'NONCE setUsed NOT IMPLEMENTED'
    for i, arg of arguments
      return arg new Error("NOT IMPLEMENTED"), false if typeof arg is 'function'


exports = module.exports = NonceStore