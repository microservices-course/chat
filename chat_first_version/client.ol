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

main
{
	if ( args[0] == "open" ) {
		openRoom@Chat( { .username = args[1], .roomName = args[2] } )( adminToken );
		println@Console( "Chat room opened. Admin token: " + adminToken )()
	} else if ( args[0] == "close" ) {
		closeRoom@Chat( { .username = args[1], .roomName = args[2], .adminToken = args[3] } )()
	} else if ( args[0] == "pub" ) {
		publish@Chat( { .username = args[1], .roomName = args[2], .message = args[3] } )()
	} else if ( args[0] == "hist" ) {
		getHistory@Chat( { .roomName = args[1] } )( history );
		println@Console( history )()
	} else if ( args[0] == "--help" ) {
		println@Console( "
Usage:
	- Open a chat room: jolie client.ol open <username> <room name> (example: jolie client.ol Jack myroom)
	- Close a chat room: jolie client.ol close <username> <room name> <admin token>
	- Publish a message: jolie client.ol pub <username> <room name> <message>
	- Get the chat history: jolie client.ol hist <room name>
	- This help: jolie client.ol --help
" )()
	}
}
