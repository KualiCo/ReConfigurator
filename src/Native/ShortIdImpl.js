var shortid = require('shortid')
var ElmNativeModule = require('elm-native-module')

module.exports = function (Elm) {
	ElmNativeModule(Elm, 'ShortId', {
	  generate: shortid.generate
	})
}
