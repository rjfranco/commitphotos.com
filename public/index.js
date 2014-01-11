var socket = eio(':8080');

socket.addEventListener('open', function () {

})

socket.addEventListener('message', function (message) {
  console.log(message)
})