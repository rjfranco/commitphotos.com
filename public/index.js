var socket = eio(':8080');

socket.addEventListener('message', function (message) {
  var main = document.querySelector('main')
    , img = document.createElement('img')

  img.src = JSON.parse(message).url

  console.log('foo')

  main.insertBefore(img, main.firstChild)
})