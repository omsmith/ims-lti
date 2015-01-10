class ConsumerError extends Error
  constructor: (@message) ->
    super
class ExtensionError extends Error
  constructor: (@message) ->
    super
class StoreError extends Error
  constructor: (@message) ->
    super
class ParameterError extends Error
  constructor: (@message) ->
    super
class SignatureError extends Error
  constructor: (@message) ->
    super
class NonceError extends Error
  constructor: (@message) ->
    super
class OutcomeResponseError extends Error
  constructor: (@message) ->
    super

module.exports =
  ConsumerError: ConsumerError
  ExtensionError: ExtensionError
  StoreError: StoreError
  ParameterError: ParameterError
  SignatureError: SignatureError
  NonceError: NonceError
  OutcomeResponseError: OutcomeResponseError
