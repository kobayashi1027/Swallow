packager = require('electron-packager')
config = require('../package.json')

packager {
  dir: './'
  out: './packages'
  name: config.name
  platform: 'darwin'
  arch: 'x64'
  'app-version': config.version
  overwrite: true
  asar: true
  prune: true
  ignore: [
    '.DS_Store',
    '/packages/*',
    '/scripts/*',
    'node_modules/(electron|electron-packager)'
  ]
}, (err, appPath) ->
  if err
    throw new Error(err)
  console.log 'Done!!'
  return
