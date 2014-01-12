var express = require('express')
  , hbs = require('hbs')
  , knox = require('knox')
  , engine = require('engine.io')
  , dotenv = require('dotenv')
  , fs = require('fs')
  , path = require('path')
  , exec = require('child_process').exec

// Laod config
dotenv.load();

var server = express()
  , io = engine.listen(8080)
  , port = 0
  , commits = []
  , es = new engine.Server()
  , sockets = []
  , media = knox.createClient({
      key: process.env.KEY
    , secret: process.env.SECRET
    , bucket: process.env.MEDIABUCKET
  })
  , json = knox.createClient({
      key: process.env.KEY
    , secret: process.env.SECRET
    , bucket: process.env.JSONBUCKET
  })

// Add client sockets to the pool
io.on('connection', function (socket) {
  sockets.push(socket)
})

// Remove client sockets from the pool
io.on('close', function (socket) {
  sockets.slice(sockets.indexOf(socket), 12)
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
json.list({}, function (err, data) {
  data.Contents = data.Contents.reverse().slice(0, 9)
  data.Contents.forEach(function (commit) {
    json.get(commit.Key).on('response', function (res) {
      res.on('data', function (chunk) {
        var data = JSON.parse(chunk.toString())
        commits.push(new Commit(data))
      })
    }).end()
  })
})

server.get('/', function (req, res){
  res.render('index', { commits: commits } );
})

server.post('/', function (req, res) {
  res.writeHead(200)
  res.end('success')

  var put
    , string
    , photo
    , now = Date.now()
    , commit = new Commit({
        id: now
      , message: req.body.message
      , name: req.body.name
      })

  if (path.extname(req.files.photo.path) === '.mov') {
    commit.url = 'http://s3.amazonaws.com/commit-photos-media/' + now + '.gif'
    exec('ffmpeg -i ' + req.files.photo.path + ' -vf scale=400:-1,format=rgb8,format=rgb24 -t 10 -r 7 uploads/' + now + '.gif', function (err, stdout, stderr) {
      if (err) throw err
      put('./uploads/' + now + '.gif', 'gif')
    })
  } else {
    commit.url = 'http://s3.amazonaws.com/commit-photos-media/' + now + '.jpg'
    put(req.files.photo.path, 'jpg')
  }

  function put(path, ext) {

    // PUT the commit
    string = JSON.stringify(commit)

    json.put('/' + commit.id + '.json', {
      'Content-Length': string.length
    , 'Content-Type': 'application/json'
    , 'x-amz-acl': 'public-read'
    }).end(string)

    // PUT the photo
    photo = fs.readFileSync(path)

    var putImage = media.put('/' + commit.id + '.' + ext, {
      'Content-Type': 'image/jpeg'
    , 'Content-Length': photo.length
    , 'x-amz-acl': 'public-read'
    }).on('response', function (req) {
                     if (req.statusCode == 200) {

                       sockets.forEach(function (socket) {
                         socket.send(string)
                       })

                       commits.unshift(commit)
                       commits = commits.splice(0, 9)

                       res.end('success!')
                     }
                   })

    putImage.end(photo)
  }
})

port = process.env.PORT || 1337
server.listen(port)
console.log("Listening on port " + port + ".")
