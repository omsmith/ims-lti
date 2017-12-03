/*
 * decaffeinate suggestions:
 * DS001: Remove Babel/TypeScript constructor workaround
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
class ConsumerError extends Error {
  constructor(message) {
    super(...arguments);
    this.message = message;
  }
}
class ExtensionError extends Error {
  constructor(message) {
    {
      // Hack: trick Babel/TypeScript into allowing this before super.
      if (false) { super(); }
      let thisFn = (() => { this; }).toString();
      let thisName = thisFn.slice(thisFn.indexOf('{') + 1, thisFn.indexOf(';')).trim();
      eval(`${thisName} = this;`);
    }
    this.message = message;
    super(...arguments);
  }
}
class StoreError extends Error {
  constructor(message) {
    super(...arguments);
    this.message = message;
  }
}
class ParameterError extends Error {
  constructor(message) {
    super(...arguments);
    this.message = message;
  }
}
class SignatureError extends Error {
  constructor(message) {
    super(...arguments);
    this.message = message;
  }
}
class NonceError extends Error {
  constructor(message) {
    super(...arguments);
    this.message = message;
  }
}
class OutcomeResponseError extends Error {
  constructor(message) {
    super(...arguments);
    this.message = message;
  }
}

module.exports = {
  ConsumerError,
  ExtensionError,
  StoreError,
  ParameterError,
  SignatureError,
  NonceError,
  OutcomeResponseError
};
