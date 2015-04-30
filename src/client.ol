/*

The MIT License (MIT)

Copyright (c) 2015 Fabrizio Montesi <famontesi@gmail.com>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

*/

include "chat.iol"
include "console.iol"

outputPort Chat {
Location: "socket://localhost:8000/"
Protocol: sodep
Interfaces: ChatInterface
}

inputPort MyInput {
Location: "socket://localhost:8001/"
Protocol: sodep
Interfaces: ClientInterface
}

main
{
	if ( args[0] == "open" ) {
		openRoom@Chat( { .username = args[1], .roomName = args[2] } )()
	} else if ( args[0] == "close" ) {
		closeRoom@Chat( { .username = args[1], .roomName = args[2] } )()
	} else if ( args[0] == "pub" ) {
		publish@Chat( { .username = args[1], .roomName = args[2], .message = args[3] } )()
	} else if ( args[0] == "hist" ) {
		getHistory@Chat( { .roomName = args[1] } )( history );
		println@Console( history )()
	} else if ( args[0] == "enter" ) {
		enterRoom@Chat( {
			.roomName = args[1],
			.location = global.inputPorts.MyInput.location
		} )();
		provide
			[ update( upd ) ] {
				m = "[" + upd.roomName + "] "
					+ upd.username + ": "
					+ upd.message;
				println@Console( m )()
			}
		until
			[ roomClosed() ]
	}
}
