electron = require "electron"
path = require "path"
url = require "url"
Config = require "electron-config"
fs = require "fs-extra"

app = electron.app
BrowserWindow = electron.BrowserWindow
Tray = electron.Tray
Menu = electron.Menu

# init models
Models = require "./lib/models"
File = Models.file
ReuseInfo = Models.reuseinfo

mainWindow = undefined

checkTarget = ->
  config = new Config
  if config.has("target")
    return true
  else
    return false

setConfig = (key, value) ->
  config = new Config
  config.set key, value

getConfig = (key) ->
  config = new Config
  config.get key

createTrayMenu = ->
  tray = new Tray(path.join __dirname, "icon.png")
  contextMenu = Menu.buildFromTemplate([
    {label: "About Swallow", click: -> createAboutWindow()},
    {type: "separator"},
    {label: "Show Finder", click: -> createFinderWindow()},
    {type: "separator"},
    {label: "Preferences", click: -> createPreferencesWindow()}
  ])
  tray.setToolTip "Swallow"
  tray.setContextMenu contextMenu

createMenu = ->
  template = [
    {
      label: 'Edit'
      submenu: [
        { role: 'undo' }
        { role: 'redo' }
        { type: 'separator' }
        { role: 'cut' }
        { role: 'copy' }
        { role: 'paste' }
        { role: 'pasteandmatchstyle' }
        { role: 'delete' }
        { role: 'selectall' }
      ]
    }
    {
      label: 'View'
      submenu: [
        { role: 'reload' }
        { role: 'forcereload' }
        { role: 'toggledevtools' }
        { type: 'separator' }
        { role: 'resetzoom' }
        { role: 'zoomin' }
        { role: 'zoomout' }
        { type: 'separator' }
        { role: 'togglefullscreen' }
      ]
    }
    {
      role: 'window'
      submenu: [
        { role: 'minimize' }
        { role: 'close' }
      ]
    }
    {
      role: 'help'
      submenu: [ {
        label: 'Learn More'
        click: ->
          require('electron').shell.openExternal 'http://electron.atom.io'
          return

      } ]
    }
  ]
  if process.platform == 'darwin'
    template.unshift
      label: app.getName()
      submenu: [
        { role: 'about' }
        { type: 'separator' }
        {
          role: 'services'
          submenu: []
        }
        { type: 'separator' }
        { role: 'hide' }
        { role: 'hideothers' }
        { role: 'unhide' }
        { type: 'separator' }
        { role: 'quit' }
      ]
    # Edit menu.
    template[1].submenu.push { type: 'separator' },
      label: 'Speech'
      submenu: [
        { role: 'startspeaking' }
        { role: 'stopspeaking' }
      ]
    # Window menu.
    template[3].submenu = [
      {
        label: 'Close'
        accelerator: 'CmdOrCtrl+W'
        role: 'close'
      }
      {
        label: 'Minimize'
        accelerator: 'CmdOrCtrl+M'
        role: 'minimize'
      }
      {
        label: 'Zoom'
        role: 'zoom'
      }
      { type: 'separator' }
      {
        label: 'Bring All to Front'
        role: 'front'
      }
    ]
  menu = Menu.buildFromTemplate(template)
  Menu.setApplicationMenu menu

createAboutWindow = ->
  mainWindow = new BrowserWindow(
    width: 800
    height: 600)
  mainWindow.loadURL url.format(
    pathname: path.join __dirname, "views/about.html"
    protocol: "file:"
    slashes: true
  )
  mainWindow.on "closed", ->
    mainWindow = null
    return
  return

createFinderWindow = ->
  mainWindow = new BrowserWindow(
    width: 1400
    height: 800
    titleBarStyle: "hidden")
  mainWindow.loadURL url.format(
    pathname: path.join __dirname, "views/finder.html"
    protocol: "file:"
    slashes: true
  )
  mainWindow.on "closed", ->
    # Dereference the window object, usually you would store windows
    # in an array if your app supports multi windows, this is the time
    # when you should delete the corresponding element.
    mainWindow = null
    return
  return

createPreferencesWindow = ->
  mainWindow = new BrowserWindow(
    width: 400
    height: 150
    titleBarStyle: "hidden")
  mainWindow.loadURL url.format(
    pathname: path.join __dirname, "views/preferences.html"
    protocol: "file:"
    slashes: true
  )
  mainWindow.on "closed", ->
    mainWindow = null
    return
  return

createSuggestWindow = ->
  childWindow = new BrowserWindow(
    parent: mainWindow
    modal: true
    width: 800
    height: 300
    titleBarStyle: "hidden")
  childWindow.loadURL url.format(
    pathname: path.join __dirname, "views/suggest.html"
    protocol: "file:"
    slashes: true
  )

createReuseFormWindow = ->
  childWindow = new BrowserWindow(
    parent: mainWindow
    modal: true
    width: 800
    height: 800
    titleBarStyle: "hidden")
  childWindow.loadURL url.format(
    pathname: path.join __dirname, "views/reuseform.html"
    protocol: "file:"
    slashes: true
  )

# for demo
createWindowFromOutsideTemplate = (path) ->
  childWindow = new BrowserWindow(
    parent: mainWindow
    width: 950
    height: 500
    titleBarStyle: "hidden")
  childWindow.loadURL url.format(
    pathname: path
    protocol: "file:"
    slashes: true
  )

module.exports =
  getConfig: getConfig
  createSuggestWindow: createSuggestWindow
  createReuseFormWindow: createReuseFormWindow
  createWindowFromOutsideTemplate: createWindowFromOutsideTemplate
  ReuseInfo: ReuseInfo


main = ->
  # (for demo) set infos to config file
  setConfig "target", path.join(app.getPath('home'), "Docs")
  setConfig "reuseSourceFile", "幹事/2016/平成27年度計算機幹事活動報告書.txt"
  setConfig "reuseDestinationFile", "幹事/2017/平成28年度計算機幹事活動報告書.txt"
  setConfig "reuseItems", ["報告書サンプル.txt", "計算機幹事仕事一覧.xlsx", "関連資料"]
  setConfig "dataDir", "その他"
  setConfig "prevReuseTime", "2016年3月17日 09:52:39"

  # (for demo) create reuseInfo database
  ReuseInfo.remove {}, multi: true
  seedReuseInfos = fs.readJsonSync path.join(getConfig("target"), "その他/reuseinfo_seeds.json")
  ReuseInfo.insert seedReuseInfos, (err) ->
    createMenu()
    createTrayMenu()

app.on "ready", main
# Quit when all windows are closed.
app.on "window-all-closed", ->
  # On OS X it is common for applications and their menu bar
  # to stay active until the user quits explicitly with Cmd + Q
  if process.platform != 'darwin'
    app.quit()
  return
app.on "activate", ->
  # On OS X it's common to re-create a window in the app when the
  # dock icon is clicked and there are no other windows open.
  if mainWindow == null
    createWindow()
  return
# In this file you can include the rest of your app's specific main process
# code. You can also put them in separate files and require them here.
