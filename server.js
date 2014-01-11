var express = require('express')
  , hbs = require('hbs')
  , knox = require('knox')
  , engine = require('engine.io')


var dotenv = require('dotenv');
dotenv.load();

var server = express()
  , sock = engine.listen(8080)
  , port = 0
  , commits = []
  , es = new engine.Server()
  , client = knox.createClient({
               key: process.env.KEY
             , secret: process.env.SECRET
             , bucket: process.env.BUCKET
             })

sock.on('connection', function (socket) {
  socket.send('foo');
})

server.set('view engine', 'html');
server.engine('html', require('hbs').__express)
server.set('views', __dirname + '/views')

server.use(express.static(__dirname + '/public'))
server.use(express.static(__dirname + '/components'))

function Commit(object) {
  this.message = object.message
  this.url = object.url
}

// Load commits
client.list({}, function (err, data) {
  data.Contents.forEach(function (commit) {
    var commit = new Commit({ url: 'http://s3.amazonaws.com/' + process.env.BUCKET + '/' + commit.Key })
    commits.push(commit)
  })
})

server.get('/', function(req, res){
  res.render('index', { commits: commits } );
})

server.post('/photos/new', function (req, res) {

})

port = process.env.PORT || 1337
server.listen(port)
console.log("Listening on port " + port + ".")
