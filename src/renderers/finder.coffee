remote = require('electron').remote.require("./main")
$ = require "jquery"
fs = require "fs"
path = require "path"
moment = require "moment"
exec = require("child_process").exec

currentTargetDir = remote.getTarget()
targetDirLogs = []

updateHeaderTitle = ->
  $("header h1.title").html("<span class='icon icon-folder icon-fw'>#{currentTargetDir}</span>")

initFilesTable = () ->
  insertFiles(currentTargetDir)

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
      </td>
      <td>#{moment(filestat.mtime).format("YYYY年MM月DD日 HH:mm")}</td>
      <td class="size">#{filestat.size} バイト</td>
      <td>#{typeJP}</td>
    </tr>
  """
  $("table#files tbody").append(data)

reloadFilesTable = ->
  $("table#files tbody").empty()
  insertFiles(currentTargetDir)

changeDir = (dirname, absolutePath = false) ->
  console.log(dirname)
  currentTargetDir = if absolutePath then dirname else path.join currentTargetDir, dirname.toString()
  updateHeaderTitle()
  reloadFilesTable()

showClickedNavContents = (navItem) ->
  tableId = navItem.attr("data-tableid")
  $("table").hide()
  $('#' + tableId).show()
  $(".nav-group-item").removeClass("active")
  navItem.addClass("active")

showMenu = (record) ->
  $("tbody tr").removeClass("active")
  record.addClass("active")
  # showmenu

ready = ->
  updateHeaderTitle()
  initFilesTable()
  $(".nav-group-item").on "click", ->
    showClickedNavContents($(this))
  $("#main").on "click", "table tbody tr", ->
    showMenu($(this))
  $("table#files tbody").on "dblclick", "tr", ->
    targetDirLogs = []
    filename = $(this).data("filename")
    if $(this).data("type") == "folder"
      changeDir(filename)
    else if $(this).data("type") == "document"
      # Notice: This command works only Mac
      exec("open #{path.join currentTargetDir, filename}")
  $("#update-button").on "click", ->
    reloadFilesTable()
  $("#prev-button").on "click", ->
    basename = path.basename(currentTargetDir)
    targetDirLogs.unshift basename if basename.length != 0
    changeDir ".."
  $("#next-button").on "click", ->
    changeDir targetDirLogs[0] if targetDirLogs.length != 0
    targetDirLogs.shift()
  $("#home-button").on "click", ->
    targetDirLogs = []
    changeDir remote.getTarget(), absolutePath = true

$(document).ready(ready)
