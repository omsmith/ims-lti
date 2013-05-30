# ims-lti


## Install
```
npm install git+ssh://git@github.com:OfficeHours/ims-lti.git
```

## Usage

The record-spy module exports a function that returns the spy object. This setup will be used later to pass configuration options to the spy object upon initalization.
```coffeescript
lti_provider = require 'ims-lti'


app.post '/lti-initalize', (req, res) ->
  customer_key = req.body.oauth_customer_key
  customer_secret =  # Pull the secret from the db
  provider = new lti_provider(customer_secret, customer_key)
  provider.verify_request req, (err, valid) ->
    if not valid
      res.send(404)
    else
      res.json(provider.body)
```

## Running Tests
To run the test suite first installing the dependencies:
```
npm install
make test
```
