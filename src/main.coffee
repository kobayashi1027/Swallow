electron = require "electron"
path = require "path"
url = require "url"
Config = require "electron-config"

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

setTarget = (target) ->
  config = new Config
  config.set "target", target

getTarget = ->
  config = new Config
  config.get "target"

createMenu = ->
  tray = new Tray(path.join __dirname, "icon.png")
  contextMenu = Menu.buildFromTemplate([
    {label: "About MyFinder", click: -> createAboutWindow()},
    {type: "separator"},
    {label: "Show Finder", click: -> createFinderWindow()},
    {type: "separator"},
    {label: "Preferences", click: -> createPreferencesWindow()}
  ])
  tray.setToolTip "MyFinder"
  tray.setContextMenu contextMenu

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
  # Create the browser window.
  mainWindow = new BrowserWindow(
    width: 800
    height: 600
    titleBarStyle: "hidden")
  # and load the index.html of the app.
  mainWindow.loadURL url.format(
    pathname: path.join __dirname, "views/finder.html"
    protocol: "file:"
    slashes: true
  )
  # Open the DevTools.
  # mainWindow.webContents.openDevTools()
  # Emitted when the window is closed.
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
    createMenu() if checkTarget()
    return
  return

main = ->
  if checkTarget()
    createMenu()
  else
    console.log "prease set target ..."
    setTarget app.getPath('home')
    # createPreferencesWindow()

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
