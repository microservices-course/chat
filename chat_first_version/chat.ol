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
include "security_utils.iol"

execution { concurrent }

inputPort ChatInput {
Location: "socket://localhost:8000/"
Protocol: sodep
Interfaces: ChatInterface
}

/*
	This implementation is *not* optimal and is intended to be used for educational purposes.

	Go ahead and find potential improvements!
*/

main
{
	[ openRoom( request )( adminToken ) {
		if ( is_defined( global.rooms.(request.roomName) ) ) {
			throw( Error )
		};
		global.rooms.(request.roomName).history = "";
		createSecureToken@SecurityUtils()( adminToken );
		global.rooms.(request.roomName).adminToken = adminToken;
		println@Console(
			"Room "
			+ request.roomName
			+ " opened by " + request.username
			+ " with admin token " + adminToken
		)()
	} ]

	[ publish( request )() {
		if ( !is_defined( global.rooms.(request.roomName) ) ) {
			throw( Error )
		};
		m = "[" + request.roomName + "] "
				+ request.username + ": "
				+ request.message;
		println@Console( m )();
		global.rooms.(request.roomName).history += m + "\n"
	} ]

	[ getHistory( request )( history ) {
		if ( !is_defined( global.rooms.(request.roomName) ) ) {
			throw( Error )
		};
		history = global.rooms.(request.roomName).history
	} ]

	[ closeRoom( request )() {
		if ( !is_defined( global.rooms.(request.roomName) ) ) {
			throw( Error )
		};
		if ( request.adminToken != global.rooms.(request.roomName).adminToken ) {
			throw( Error )
		};
		println@Console(
			"Room "
			+ request.roomName
			+ " closed by " + request.username
		)()
	} ]
}
