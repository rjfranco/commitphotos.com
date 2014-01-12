var express = require('express')
  , hbs = require('hbs')
  , knox = require('knox')
  , engine = require('engine.io')
  , dotenv = require('dotenv')
  , fs = require('fs')

// Laod config
dotenv.load();

var server = express()
  , io = engine.listen(8080)
  , port = 0
  , commits = []
  , es = new engine.Server()
  , sockets = []
  , client = knox.createClient({
               key: process.env.KEY
             , secret: process.env.SECRET
             , bucket: process.env.BUCKET
             })

// Add client sockets to the pool
io.on('connection', function (socket) {
  sockets.push(socket)
})

// Remove client sockets from the pool
io.on('close', function (socket) {
  sockets.slice(sockets.indexOf(socket), 1)
})

server.use(express.bodyParser({ uploadDir :'./uploads' }))
server.set('view engine', 'html');
server.engine('html', require('hbs').__express)
server.set('views', __dirname + '/views')

server.use(express.static(__dirname + '/public'))
server.use(express.static(__dirname + '/components'))

function Commit(object) {
  this.message = object.message
  this.url = object.url
  this.id = object.id
  this.name = object.name
}

// Load commits
client.list({}, function (err, data) {
  data.Contents.forEach(function (commit) {
    var commit = new Commit({ url: 'http://s3.amazonaws.com/' + process.env.BUCKET + '/' + commit.Key })
    commits.push(commit)
  })
})

server.get('/', function (req, res){
  res.render('index', { commits: commits } );
})

server.post('/photos/new', function (req, res) {
  var put
    , string
    , photo
    , now = Date.now()
    , commit = new Commit({
        id: now
      , message: req.body.message
      , name: req.body.name
      , url: 'http://s3.amazonaws.com/commit-photos-dev/' + now + '.jpg'
      })

  // PUT the commit
  string = JSON.stringify(commit)
  client.put('/' + commit.id + '.json', {
    'Content-Length': string.length
  , 'Content-Type': 'application/json'
  , 'x-amz-acl': 'public-read'
  }).end(string)

  // PUT the photo
  photo = fs.readFileSync(req.files.photo.path)
  var putImage = client.put('/' + commit.id + '.jpg', {
    'Content-Type': 'image/jpeg'
  , 'Content-Length': photo.length
  , 'x-amz-acl': 'public-read'
  }).on('response', function (req) {
                   if (req.statusCode == 200) {
                     sockets.forEach(function (socket) {
                       socket.send(string)
                     })

                     commits.push(commit)

                     res.end('success!')
                   }
                 })

  putImage.end(photo)

})

port = process.env.PORT || 1337
server.listen(port)
console.log("Listening on port " + port + ".")
