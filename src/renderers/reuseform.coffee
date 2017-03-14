remote = require('electron').remote
main = remote.require("./main")
$ = require "jquery"
path = require "path"
fs = require "fs-extra"
moment = require "moment"

# Datastore
ReuseInfo = main.ReuseInfo

folderIcon = "<span class='icon icon-folder icon-text'></span>"
fileIcon = "<span class='icon icon-doc-text icon-text'></span>"
removeIcon = "<span class='icon icon-cancel icon-text'></span>"

reuseSource = path.join main.getConfig("target"), main.getConfig("reuseSourceFile")
reuseDestination = path.join main.getConfig("target"), main.getConfig("reuseDestinationFile")
otherReuseItems = main.getConfig "reuseItems"

insertFolderName = ->
  $("input#reuse-dest-folder").val(path.dirname reuseDestination)

insertFileName = ->
  $("input#reuse-dest-file").val(path.basename reuseDestination)

insertReuseItems = ->
  otherReuseItems.forEach (item) ->
    folder = path.dirname reuseSource
    file = fs.statSync path.join(folder, item)
    icon = if file.isDirectory() then folderIcon else fileIcon
    data = """
      <button type="button" class="btn btn-default">
        #{removeIcon} #{icon}
        #{item}
      </button>
    """
    $("pre#reuse-items").append(data)

doReuse = ->
  fs.copySync reuseSource, reuseDestination
  createReuseInfo reuseSource, reuseDestination
  otherReuseItems.forEach (item) ->
    src = path.join (path.dirname reuseSource), item
    dest = path.join (path.dirname reuseDestination), item
    fs.copySync src, dest
    createReuseInfo src, dest

createReuseInfo = (source, destination) ->
  fileStat = fs.statSync source
  type = if fileStat.isDirectory() then "folder" else "document"
  reuseInfo =
    source: path.basename source
    destination: path.basename destination
    type: type
    time: moment().format("YYYY-MM-DD HH:mm")
  ReuseInfo.insert reuseInfo

ready = ->
  insertFolderName()
  insertFileName()
  insertReuseItems()
  $("#cancel-button").on "click", ->
    remote.getCurrentWindow().close()
  $("#ok-button").on "click", ->
    doReuse()
    remote.getCurrentWindow().close()

$(document).ready(ready)
