var socket = eio(':1337');

socket.addEventListener('message', function (message) {
  console.log(message)
  $($('.commit').get(Math.round(Math.random() * $('.commit').length))).html('<img src="' + JSON.parse(message).url + '" /></div>')
})