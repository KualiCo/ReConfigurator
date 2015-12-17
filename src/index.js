'use strict'

require('./index.html')
require('./style.styl')
var Elm = require('./Main')
var shortid = require('shortid')
var ElmNativeModule = require('elm-native-module')

ElmNativeModule(Elm, 'ShortId', {
  generate: shortid.generate
})

Elm.embed(Elm.Main, document.getElementById('main'),
	{ storedApiInfo:
		{ url: "http://localhost:4000"
		, key: "blah"
		}
	}
)

