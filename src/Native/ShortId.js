// The actual implementation of ShortId is in ShortIdImpl.js
// This file is just here to make the Elm compiler happy.
// The conditional require below runs when this file is
// being loaded by Node.js (in the repl, or during 
// automated test running.)

if (typeof window == 'undefined') {
	require('./src/Native/ShortIdImpl')(Elm)
}
