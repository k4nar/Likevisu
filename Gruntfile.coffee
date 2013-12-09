# Generated on 2013-11-26 using generator-angular-fullstack 0.2.0
"use strict"

# # Globbing
# for performance reasons we're only matching one level down:
# 'test/spec/{,*/}*.js'
# use this if you want to recursively match all subfolders:
# 'test/spec/**/*.js'
module.exports = (grunt) ->
  require("load-grunt-tasks") grunt
  require("time-grunt") grunt

  grunt.loadNpmTasks 'grunt-contrib-jade'

  grunt.initConfig
    yeoman:

      # configurable paths
      app: require("./bower.json").appPath or "app"
      dist: "public"

    open:
      server:
        url: "http://localhost:5000/"

    watch:
      coffee:
        files: ["<%= yeoman.app %>/scripts/{,*/}*.coffee"]
        tasks: ["coffee:dist"]

      flask:
        files: ["{,*/}*.py"]
        tasks: ["flask"]

      compass:
        files: ["<%= yeoman.app %>/styles/{,*/}*.{scss,sass}"]
        tasks: ["compass:server", "autoprefixer"]

      styles:
        files: ["<%= yeoman.app %>/styles/{,*/}*.css"]
        tasks: ["copy:styles", "autoprefixer"]

      gruntfile:
        files: ["Gruntfile.coffee"]

      jade:
        files: ['<%= yeoman.app %>/{,*//*}*.jade']
        tasks: ['jade:dist']

    autoprefixer:
      options: ["last 1 version"]
      dist:
        files: [
          expand: true
          cwd: ".tmp/styles/"
          src: "{,*/}*.css"
          dest: ".tmp/styles/"
        ]

    clean:
      dist:
        files: [
          dot: true
          src: [".tmp", "<%= yeoman.dist %>/*", "!<%= yeoman.dist %>/.git*"]
        ]

      heroku:
        files: [
          dot: true
          src: ["heroku/*", "!heroku/.git*", "!heroku/Procfile"]
        ]

      server: ".tmp"

    coffee:
      options:
        sourceMap: true
        sourceRoot: ""

      dist:
        files: [
          expand: true
          cwd: "<%= yeoman.app %>/scripts"
          src: "{,*/}*.coffee"
          dest: ".tmp/scripts"
          ext: ".js"
        ]

    compass:
      options:
        sassDir: "<%= yeoman.app %>/styles"
        cssDir: ".tmp/styles"
        generatedImagesDir: ".tmp/images/generated"
        imagesDir: "<%= yeoman.app %>/images"
        javascriptsDir: "<%= yeoman.app %>/scripts"
        fontsDir: "<%= yeoman.app %>/fonts"
        importPath: "<%= yeoman.app %>/bower_components"
        httpImagesPath: "/images"
        httpGeneratedImagesPath: "/images/generated"
        httpFontsPath: "/fonts"
        relativeAssets: false

      dist: {}
      server:
        options:
          debugInfo: true

    jade:
      dist:
          files: [
              expand: true
              cwd: '<%= yeoman.app %>'
              src: '{,*/}*.jade'
              dest: '.tmp'
              ext: '.html'
          ]


    # not used since Uglify task does concat,
    # but still available if needed
    #concat: {
    #      dist: {}
    #    },
    rev:
      dist:
        files:
          src: ["<%= yeoman.dist %>/scripts/{,*/}*.js", "<%= yeoman.dist %>/styles/{,*/}*.css", "<%= yeoman.dist %>/images/{,*/}*.{png,jpg,jpeg,gif,webp,svg}", "<%= yeoman.dist %>/styles/fonts/*"]

    useminPrepare:
      html: ".tmp/index.html"
      options:
        dest: "<%= yeoman.dist %>"

    usemin:
      html: ["<%= yeoman.dist %>/{,*/}*.html"]
      css: ["<%= yeoman.dist %>/styles/{,*/}*.css"]
      options:
        assetsDirs: ["<%= yeoman.dist %>"]

    svgmin:
      dist:
        files: [
          expand: true
          cwd: "<%= yeoman.app %>/images"
          src: "{,*/}*.svg"
          dest: "<%= yeoman.dist %>/images"
        ]

    cssmin: {}

    # By default, your `index.html` <!-- Usemin Block --> will take care of
    # minification. This option is pre-configured if you do not wish to use
    # Usemin blocks.
    # dist: {
    #   files: {
    #     '<%= yeoman.dist %>/styles/main.css': [
    #       '.tmp/styles/{,*/}*.css',
    #       '<%= yeoman.app %>/styles/{,*/}*.css'
    #     ]
    #   }
    # }
    htmlmin:
      dist:
        options: {}

        #removeCommentsFromCDATA: true,
        #          // https://github.com/yeoman/grunt-usemin/issues/44
        #          //collapseWhitespace: true,
        #          collapseBooleanAttributes: true,
        #          removeAttributeQuotes: true,
        #          removeRedundantAttributes: true,
        #          useShortDoctype: true,
        #          removeEmptyAttributes: true,
        #          removeOptionalTags: true
        files: [
          expand: true
          cwd: ".tmp"
          src: ["*.html", "views/*.html"]
          dest: "<%= yeoman.dist %>"
        ]


    # Put files not handled in other tasks here
    copy:
      dist:
        files: [
          expand: true
          dot: true
          cwd: "<%= yeoman.app %>"
          dest: "<%= yeoman.dist %>"
          src: ["*.{ico,png,txt}", ".htaccess", "bower_components/**/*", "images/{,*/}*.{gif,webp}", "fonts/*"]
        ,
          expand: true
          cwd: ".tmp/images"
          dest: "<%= yeoman.dist %>/images"
          src: ["generated/*"]
        ]

      heroku:
        files: [
          expand: true
          dot: true
          dest: "heroku"
          src: ["<%= yeoman.dist %>/**"]
        ,
          expand: true
          dest: "heroku"
          src: ["package.json", "server.coffee", "lib/**/*"]
        ]

      styles:
        expand: true
        cwd: "<%= yeoman.app %>/styles"
        dest: ".tmp/styles/"
        src: "{,*/}*.css"

    concurrent:
      server: ["jade:dist", "coffee:dist", "compass:server", "copy:styles"]
      dist: ["jade:dist", "coffee", "compass:dist", "copy:styles", "imagemin", "svgmin", "htmlmin"]

    cdnify:
      dist:
        html: ["<%= yeoman.dist %>/*.html"]

    ngmin:
      dist:
        files: [
          expand: true
          cwd: ".tmp/concat/scripts"
          src: "*.js"
          dest: ".tmp/concat/scripts"
        ]

    uglify:
      dist:
        files:
          "<%= yeoman.dist %>/scripts/scripts.js": ["<%= yeoman.dist %>/scripts/scripts.js"]

  grunt.registerTask "flask", "Run flask server.", ->
    spawn = require("child_process").spawn
    grunt.log.writeln "Starting Flask development server."

    # stdio: 'inherit' let us see flask output in grunt
    process.env.FLASK_ROOT = 'app'
    process.env.FLASK_ROOT = '.tmp'
    PIPE = stdio: "inherit"
    spawn "python", ["server.py"], PIPE

  grunt.registerTask "server", (target) ->
    return grunt.task.run(["build", "open"])  if target is "dist"
    grunt.task.run ["clean:server", "concurrent:server", "autoprefixer", "flask", "open", "watch"]

  grunt.registerTask "build", ["clean:dist", "jade:dist", "useminPrepare", "concurrent:dist", "autoprefixer", "concat", "ngmin", "copy:dist", "cdnify", "cssmin", "uglify", "rev", "usemin"]
  grunt.registerTask "heroku", ["build", "clean:heroku", "copy:heroku"]
  grunt.registerTask "default", ["server"]