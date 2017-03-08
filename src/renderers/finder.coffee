remote = require('electron').remote
$ = require("jquery")

initTables = ->
  $("span#files-table").load("components/files-table.html")
  $("span#reuselogs-table").load("components/reuselogs-table.html")

showClickedNavContents = (navItem) ->
  tableId = navItem.attr("data-tableid")
  $("table").hide()
  $('#' + tableId).show()
  $(".nav-group-item").removeClass("active")
  navItem.addClass("active")

showMenu = (record) ->
  console.log "clicked!!!"
  $("tbody tr").removeClass("active")
  record.addClass("active")
  # showmenu

ready = ->
  initTables()
  $(".nav-group-item").on "click", ->
    showClickedNavContents($(this))
  $("#main").on "click", "table tbody tr", ->
    showMenu($(this))

$(document).ready(ready)
