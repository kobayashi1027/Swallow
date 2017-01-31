gulp   = require "gulp"
coffee = require "gulp-coffee"
sass   = require "gulp-sass"

gulp.task "compile-coffee", ->
  gulp.src "src/**/*.coffee"
    .pipe coffee()
    .pipe gulp.dest "app"

gulp.task "compile-sass", ->
  gulp.src "src/**/*.scss"
    .pipe sass()
    .pipe gulp.dest "app"
  gulp.src "src/**/*.css"
    .pipe gulp.dest "app"

gulp.task "compile-html", ->
  gulp.src "src/**/*.html"
    .pipe gulp.dest "app"

gulp.task "compile-vendor", ->
  gulp.src "vendor/**/*"
    .pipe gulp.dest "app"

gulp.task "compile", [
  "compile-coffee",
  "compile-sass",
  "compile-html",
  "compile-vendor"
  ]
