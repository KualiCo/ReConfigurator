'use strict'

require('./index.html')
require('./style.styl')
var Elm = require('./Main')
require('./Native/ShortIdImpl')(Elm)

Elm.embed(Elm.Main, document.getElementById('main'),
	{ storedApiInfo:
		{ url: "http://localhost:4000"
		, key: "blah"
		}
	}
)

