'use strict'

require('./index.html')
require('./style.styl')
var Elm = require('./Main')
var shortid = require('shortid')

Elm.embed(Elm.Main, document.getElementById('main'),
	{ storedApiInfo:
		{ url: "http://localhost:4000"
		, key: "blah"
		}
	}
)


function ElmNativeModule(name, values) {
    Elm.Native[name] = {};
    Elm.Native[name].make = function(elm) {
        elm.Native = elm.Native || {};
        elm.Native[name] = elm.Native[name] || {};
        if (elm.Native[name].values) return elm.Native[name].values;
        return elm.Native[name].values = values;
    };
}


ElmNativeModule('ShortId', {
	generate: shortid.generate
})