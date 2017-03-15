remote = require('electron').remote
main = remote.require("./main")
$ = require "jquery"
path = require "path"
fs = require "fs-extra"
moment = require "moment"
ipcRenderer = require("electron").ipcRenderer

# Datastore
ReuseInfo = main.ReuseInfo

# icons
folderIcon = "<span class='icon icon-folder icon-fw'></span>"
fileIcon = "<span class='icon icon-doc-text icon-fw'></span>"

# Get reuse-souce path from main process
reuseSource = ipcRenderer.sendSync("getReuseSourcePath")
sourceStat = fs.statSync reuseSource

# Insert files and folders in the directory to window
insertChildren = (parentPath) ->
  fs.readdir parentPath, (err, files) ->
    files.forEach (file) ->
      filestat = fs.statSync path.join(parentPath, file)
      icon = if filestat.isDirectory() then folderIcon else fileIcon
      data = """
        <div class="checkbox">
          <label>
            <input type="checkbox" checked> #{icon} #{file}
          </label>
        </div
      """
      $("div#reuse-items").append(data)

# Update header title to reuse-source name
updateHeaderTitle = ->
  icon = if sourceStat.isDirectory() then folderIcon else fileIcon
  $("header h1.title").html("#{icon}#{path.basename reuseSource} の再利用")

# Update label name according to the file type of reuse-source
updateReuseDestLabel = ->
  type = if sourceStat.isDirectory() then "フォルダ" else "ファイル"
  $("input#reuse-dest").prev("label").html("再利用先#{type}名:")

ready = ->
  updateHeaderTitle()
  updateReuseDestLabel()
  if sourceStat.isDirectory()
    insertChildren(reuseSource)
  else
    $("div#reuse-items").remove()
  $("#cancel-button").on "click", ->
    remote.getCurrentWindow().close()
  $("#ok-button").on "click", ->
    # TODO: do reuse
    remote.getCurrentWindow().close()

$(document).ready(ready)
