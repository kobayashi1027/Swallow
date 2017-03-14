remote = require('electron').remote
main = remote.require("./main")
$ = require "jquery"
path = require "path"
exec = require("child_process").exec

suggestFile = path.join main.getConfig("target"), main.getConfig("reuseSourceFile")
prevReuseTime = main.getConfig "prevReuseTime"

folderIcon = "<span class='icon icon-folder icon-fw'></span>"
fileIcon = "<span class='icon icon-doc-text icon-fw'></span>"

insertMessage = ->
  data = """
    <div><span class='filename'>#{folderIcon}#{path.dirname suggestFile}</span>内の</div>
	  <div><span class='filename'>#{fileIcon}#{path.basename suggestFile}</span>を</div>
	  <div>再利用してはいかがでしょうか？</div>
	  <div>(前回の再利用: #{prevReuseTime})</div>
  """
  $("div.msg-area").html(data)

ready = ->
  insertMessage()
  $("#preview-button").on "click", ->
    # Notice: This command works only Mac
    exec("open #{suggestFile}")
  $("#cancel-button").on "click", ->
    remote.getCurrentWindow().close()
  $("#ok-button").on "click", ->
    main.createReuseFormWindow()
    remote.getCurrentWindow().close()

$(document).ready(ready)
