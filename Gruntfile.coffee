module.exports = (grunt) ->

  grunt.initConfig

    compass:
      dist:
        sassDir: 'src'
        cssDir: 'public/styles'
        options:
          config: 'config.rb'

    coffee:
      'public/scripts/index.js': 'src/index.coffee'

    watch:
      html:
        files: ['views/*.jade']
      sass:
        files: ['src/*.sass']
        tasks: ['compass']
      coffee:
        files: ['src/*.coffee']
        tasks: ['coffee']
      options:
        livereload: true

  grunt.loadNpmTasks('grunt-contrib-compass')
  grunt.loadNpmTasks('grunt-contrib-coffee')
  grunt.loadNpmTasks('grunt-contrib-watch')
  grunt.registerTask('default', ['compass', 'coffee', 'watch'])
