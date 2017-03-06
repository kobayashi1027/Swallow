Datastore = require "nedb"
path = require "path"
dbPath = require("electron").app.getPath("userData")

File = new Datastore(
  filename: path.join dbPath, "files.db"
  autoload: true
)

ReuseInfo = new Datastore(
  filename: path.join dbPath, "reuseinfos.db"
  autoload: true
)

module.exports =
  file: File
  reuseinfo: ReuseInfo
