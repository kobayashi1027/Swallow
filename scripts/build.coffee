packager = require 'electron-packager'
config   = require '../package.json'
devDeps  = Object.keys config.devDependencies

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
    '/packages($|/)',
    '/scripts($|/)',
    '/attic($|/)'
  ].concat devDeps.map((name) -> '/node_modules/' + name + '($|/)')
}, (err, appPath) ->
  if err
    throw new Error(err)
  console.log 'Done!!'
  return
