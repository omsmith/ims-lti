# ims-lti

[![Build Status](https://travis-ci.org/omsmith/ims-lti.svg?branch=master)](https://travis-ci.org/omsmith/ims-lti)

This is a nodejs library used to help create Tool Providers for the
[IMS LTI standard](http://www.imsglobal.org/lti/index.html). Tool Consumer implmentation is left as an excersise to the reader :P

## Install
```
npm install ims-lti --save
```

To require the library into your project
```coffeescript
require 'ims-lti'
```

## Usage

The LTI standard won't be covered here, but it would be good to familiarize yourself with the specs. [LTI documentation](http://www.imsglobal.org/lti/index.html)

This library doesn't help you manage or distribute the consumer keys and secrets. The POST
parameters will contain the `oauth_consumer_key` and your application should use that to look up the consumer secret from your own datastore.

This library offers a few interfaces to use for managing the OAuth nonces to make sure the same nonce
isn't used twice with the same timestamp. [Read the LTI documentation on OAuth](http://www.imsglobal.org/LTI/v1p1pd/ltiIMGv1p1pd.html#_Toc309649687). They will be covered below.

### Setting up a Tool Provider (TP)
As a TP your app will receive a POST request with [LTI launch data](http://www.imsglobal.org/lti/v1p1pd/ltiIMGv1p1pd.html#_Toc309649684) that will be signed with OAuth using a key/secret that both the TP and Tool Consumer (TC) share. This is all covered in the [LTI security model](http://www.imsglobal.org/lti/v1p1pd/ltiIMGv1p1pd.html#_Toc309649685)

Once you find the `oauth_consumer_secret` based on the `oauth_consumer_key` in the POST request, you can initialize a `Provider` object with them and a few other optional parameters:

```coffeescript
lti = require 'ims-lti'

provider = new lti.Provider consumer_key, consumer_secret, [nonce_store=MemoryStore], [signature_method=HMAC_SHA1]
```

Once the provider has been initialized, a reqest object can be validated against it. During validation, OAuth signatures are checked against the passed consumer_secret and signautre_method ( HMAC_SHA1 assumed ). isValid returns true if the request is an lti request and is properly signed.

```coffeescript
provider.valid_request req, (err, isValid) ->
  # isValid = Boolean | always false if err
  # err = Error object with method descibing error if err, null if no error
```

After validating the reqest, the provider object both stores the requests parameters (excluding oauth parameters) and provides convinience accessors to common onces including `provider.student`, `provider.ta`, `provider.username`, and more. All request data can be accessed through `provider.body` in an effort to namespace the values.

Currently there is not an emplementation for posting back to the Tool Consumer, although there is a boolean accessor `provider.outcome_service` that will return true if the TC will accept a POSTback.

### Nonce Stores

`ims-lti` does not standardize the way in which the OAuth nonce/timestamp is to be stored. Since it is a crutial part of OAuth security, this library implements an Interface to allow the user to implement their own nonce-stores.

#### Nonce Interface
All custom Nonce stores should extend the NonceStore class and implment `isNew` and `setUsed`
```coffeescript
class NonceStore
  isNew:   (nonce,timestamp,callback)=>
    # Sets any new nonce to used
  setUsed: (nonce,timestamp,callback)=>
```

Two nonce stores have been implemented for convinience.

#### MemoryNonceStore
The default nonce store (if none is specified) is the Memory Nonce Store. This store simply keeps an array of nocne/timestamp keys. Timestamps must be valid within a 5 minute grace period.

#### RedisNonceStore
A superior nonce store is the RedisNonceStore. This store requires a secondary input into the constructor, a redis-client. The redis client is used to store the nonce keys and set them to expire within a set amount of time (default 5 minutes). A RedisNonceStore is initialized like:

```coffeescript
RedisNonceStore = require '../lib/redis-nonce-store'
client          = require('redis').createClient()
store           = new RedisNonceStore('consumer_key', client)

provider = new lti.Provider consumer_key, consumer_secret, store
```

## Running Tests
To run the test suite first installing the dependencies:
```
npm install
make test
```
