class NonceStore {

  constructor() {
    this.isNew = this.isNew.bind(this);
    this.setUsed = this.setUsed.bind(this);
  }

  isNonceStore() { return true; }

  isNew(){
    for (let i in arguments) {
      const arg = arguments[i];
      if (typeof arg === 'function') { return arg(new Error("NOT IMPLEMENTED"), false); }
    }
  }

  setUsed(){
    for (let i in arguments) {
      const arg = arguments[i];
      if (typeof arg === 'function') { return arg(new Error("NOT IMPLEMENTED"), false); }
    }
  }
}


const exports = (module.exports = NonceStore);
