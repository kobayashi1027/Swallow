remote = require('electron').remote
main = remote.require("./main")
$ = require "jquery"
path = require "path"
fs = require "fs-extra"

folderIcon = "<span class='icon icon-folder icon-text'></span>"
fileIcon = "<span class='icon icon-doc-text icon-text'></span>"
removeIcon = "<span class='icon icon-cancel icon-text'></span>"

reuseSource = path.join main.getTarget(), "manager-work/2016/平成27年度計算機幹事活動報告書.txt"
reuseDestination = path.join main.getTarget(), "manager-work/2017/平成28年度計算機幹事活動報告書.txt"
otherReuseItems = [
  "計算機幹事仕事一覧.txt"
  "活動記録.xlsx"
  "関連資料"
]

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
  otherReuseItems.forEach (item) ->
    src = path.join (path.dirname reuseSource), item
    dest = path.join (path.dirname reuseDestination), item
    fs.copySync src, dest

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
