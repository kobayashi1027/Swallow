remote = require('electron').remote
main = remote.require("./main")
$ = require "jquery"
fs = require "fs-extra"
path = require "path"
moment = require "moment"
exec = require("child_process").exec

# Datastore
ReuseInfo = main.ReuseInfo

currentTargetDir = main.getTarget()
targetDirLogs = []
# for demo
reuseFileName = "平成28年度計算機幹事活動報告書.txt"
dataPath = path.join main.getTarget(), "その他"
editIconTag = "<span class='icon icon-pencil icon-fw'></span>"

updateHeaderTitle = ->
  $("header h1.title").html("<span class='icon icon-folder icon-fw'>#{currentTargetDir}</span>")

initFilesTable = () ->
  insertFiles(currentTargetDir)
  insertReuseInfos()

insertFiles = (targetDir) ->
  fs.readdir targetDir, (err, files) ->
    throw err if err
    files.forEach (file) ->
      insertFile(path.join(targetDir, file))

insertFile = (filePath) ->
  filestat = fs.statSync filePath
  filename = path.basename filePath
  if filestat.isDirectory()
    iconTag = "<span class='icon icon-folder icon-fw'></span>"
    type = "folder"
    typeJP = "フォルダ"
  else
    iconTag = "<span class='icon icon-doc-text icon-fw'></span>"
    type = "document"
    typeJP = "ドキュメント"
  data = """
    <tr data-filename="#{filename}" data-type="#{type}">
      <td>
        #{iconTag}
        #{filename}
        #{if filename == reuseFileName then editIconTag else ''}
      </td>
      <td>#{moment(filestat.mtime).format("YYYY年MM月DD日 HH:mm")}</td>
      <td class="size">#{filestat.size} バイト</td>
      <td>#{typeJP}</td>
    </tr>
  """
  $("table#files tbody").append(data)

insertReuseInfos = ->
  ReuseInfo.find({}).sort(time: 1).exec (err, reuseInfos) ->
    reuseInfos.forEach (reuseInfo) ->
      insertReuseInfo reuseInfo

insertReuseInfo = (reuseInfo) ->
  if reuseInfo.type == "document"
    iconTag = "<span class='icon icon-doc-text icon-fw'></span>"
  else if reuseInfo.type == "folder"
    iconTag = "<span class='icon icon-folder icon-fw'></span>"
  data = """
    <tr>
      <td>#{iconTag} #{reuseInfo.source}</td>
      <td>#{iconTag} #{reuseInfo.destination}</td>
      <td>#{moment(reuseInfo.time).format("YYYY年MM月DD日 HH:mm")}</td>
    </tr>
  """
  $("table#reuseinfos tbody").append(data)

reloadFilesTable = ->
  $("table#files tbody").empty()
  insertFiles(currentTargetDir)

reloadReuseInfosTable = ->
  $("table#reuseinfos tbody").empty()
  insertReuseInfos()

changeDir = (dirname, absolutePath = false) ->
  currentTargetDir = if absolutePath then dirname else path.join currentTargetDir, dirname.toString()
  updateHeaderTitle()
  reloadFilesTable()

showClickedNavContents = (navItem) ->
  tableId = navItem.attr("data-tableid")
  $("table").hide()
  $('#' + tableId).show()
  $(".nav-group-item").removeClass("active")
  navItem.addClass("active")

activateItem = (record) ->
  $("tbody tr").removeClass("active")
  record.addClass("active")

showContextMenu = ->
  template = [
    {label: "開く"}
    {label: "このファイルを再利用"}
    {type: "separator"},
    {label: "情報を見る"}
  ]
  contextMenu = remote.Menu.buildFromTemplate(template)
  contextMenu.popup(remote.getCurrentWindow(), async: true)

ready = ->
  updateHeaderTitle()
  initFilesTable()
  $(".nav-group-item").on "click", ->
    showClickedNavContents($(this))
  $("#main").on "click", "table tbody tr", ->
    activateItem($(this))
  $("table#files tbody").on "dblclick", "tr", ->
    targetDirLogs = []
    filename = $(this).data("filename")
    if $(this).data("type") == "folder"
      changeDir(filename)
    else if $(this).data("type") == "document"
      # Notice: This command works only Mac
      exec("open #{path.join currentTargetDir, filename}")
  $("table#files tbody").on "contextmenu", "tr", ->
    activateItem($(this))
    showContextMenu()
  $("#update-button").on "click", ->
    reloadFilesTable()
    reloadReuseInfosTable()
  $("#prev-button").on "click", ->
    basename = path.basename(currentTargetDir)
    targetDirLogs.unshift basename if basename.length != 0
    changeDir ".."
  $("#next-button").on "click", ->
    changeDir targetDirLogs[0] if targetDirLogs.length != 0
    targetDirLogs.shift()
  $("#home-button").on "click", ->
    targetDirLogs = []
    changeDir main.getTarget(), absolutePath = true
  $("#notification-button").on "click", ->
    main.createSuggestWindow()
  $("table#files").on "click", ".icon-pencil", ->
    $(this).parent()
    main.createWindowFromOutsideTemplate path.join(dataPath, "diff.html")

$(document).ready(ready)
