var net = require('net'),
    JsonSocket = require('json-socket');
 
var port = 3031;
var server = net.createServer();
server.listen(port);
server.on('connection', function(socket) { //This is a standard net.Socket
    socket = new JsonSocket(socket); //Now we've decorated the net.Socket to be a JsonSocket
    socket.on('message', function(message) {
        console.log(message)
    });
});