var socket = eio(':8080');

socket.addEventListener('message', function (message) {
  console.log(message)
  $('main:last-child').remove()
  $('main').prepend('<img src="' + JSON.parse(message).url + '" />')
})