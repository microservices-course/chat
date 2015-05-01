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

execution { concurrent }

inputPort ChatInput {
Location: "socket://localhost:8000/"
Protocol: sodep
Interfaces: ChatInterface
}

outputPort Client {
Protocol: sodep
Interfaces: ClientInterface
}

cset {
roomName:
	OpenRoomRequest.roomName
	CloseRoomRequest.roomName
	PublishRequest.roomName
	GetHistory.roomName
	EnterRoomRequest.roomName
}

define updateClients
{
	for( i = 0, i < #clients, i++ ) {
		Client.location = clients[i].location;
		update@Client( pubReq )
	}
}

define closeClients
{
	for( i = 0, i < #clients, i++ ) {
		Client.location = clients[i].location;
		roomClosed@Client()
	}
}

main
{
	openRoom( openReq )( openResp ) {
		csets.roomName = openReq.roomName;
		println@Console(
			"Created room "
			+ openReq.roomName
			+ " by " + openReq.username
		)()
	};
	history = "";
	provide
		[ publish( pubReq )() {
			m = "[" + pubReq.roomName + "] "
				+ pubReq.username + ": "
				+ pubReq.message;
			println@Console( m )();
			history += m + "\n";
			updateClients
		} ]

		[ getHistory()( history ) {
			nullProcess
		} ]

		[ enterRoom( enterRoomReq )() {
			clients[#clients].location = enterRoomReq.location
		} ]
	until
		[ closeRoom( closeReq )() {
			println@Console(
				"Closed room "
				+ closeReq.roomName
				+ " by " + closeReq.username
			)();
			closeClients
		} ]
}
