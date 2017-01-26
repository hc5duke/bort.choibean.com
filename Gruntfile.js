(function(){
  module.exports = function(grunt) {
    grunt.initConfig({
      concurrent: {
        default: {
          tasks: [
            'nodemon', // express server on dist
            'watch'    // watch and compile code
          ],
          options: { logConcurrentOutput: true }
        },
      },

      aws: grunt.file.readJSON('.grunt-aws.json'),

      s3: {
        options: {
          key: '<%= aws.key %>',
          secret: '<%= aws.secret %>',
          bucket: '<%= aws.bucket %>',
          access: 'public-read',
          region: 'us-west-1',
          headers: {
            // Two Year cache policy (1000 * 60 * 60 * 24 * 730)
            "Cache-Control": "max-age=630720000, public",
            "Expires": new Date(Date.now() + 63072000000).toUTCString()
          }
        },
        default: {
          upload: [
            { src: 'dist/index.html', dest: '/index.html' },
            { src: 'res/touch-icon-ipad-retina.png', dest: '/touch-icon-ipad-retina.png' },
            { src: 'res/touch-icon-ipad.png', dest: '/touch-icon-ipad.png' },
            { src: 'res/touch-icon-iphone-retina.png', dest: '/touch-icon-iphone-retina.png' },
            { src: 'res/touch-icon-iphone.png', dest: '/touch-icon-iphone.png' },
          ]
        }
      },

      haml: {
        dist: {
          files: { 'tmp/index.html': 'src/index.haml' }
        }
      },

      coffee: {
        compile: {
          files: { 'tmp/bart.js': ['src/bart.coffee'] }
        }
      },

      sass: {
        dist: {
          options: { style: 'expanded' },
          files: { 'tmp/bart.css': 'src/bart.scss' }
        }
      },

      uglify: {
        my_target: {
          files: { 'tmp/bart.min.js': ['tmp/bart.js'] }
        }
      },

      cssmin: {
        combine: {
          files: { "tmp/bart.min.css": ["tmp/bart.css"] }
        }
      },

      htmlmin: {
        dist: {
          options: {
            removeComments: true,
            collapseWhitespace: true
          },
          files: {
            'dist/index.html': 'tmp/index.html',
          }
        }
      },

      nodemon: {
        dev: {
          script: 'server.js',
          options: {
            verbose: false
          },
          ignore: ['*'] // don't need to restart server
        }
      },

      watch: {
        files: ['src/*'],
        tasks: ['prep-dist-dir']
      }
    });

    grunt.loadNpmTasks('grunt-concurrent');
    grunt.loadNpmTasks('grunt-contrib-coffee');
    grunt.loadNpmTasks('grunt-contrib-haml');
    grunt.loadNpmTasks('grunt-contrib-sass');
    grunt.loadNpmTasks('grunt-contrib-watch');
    grunt.loadNpmTasks('grunt-contrib-uglify');
    grunt.loadNpmTasks('grunt-contrib-cssmin');
    grunt.loadNpmTasks('grunt-contrib-htmlmin');
    grunt.loadNpmTasks('grunt-nodemon');
    grunt.loadNpmTasks('grunt-s3');

    // launch time bootstrap tasks
    grunt.registerTask('deploy', [ 'prep-dist-dir', 's3' ]);
    grunt.registerTask('fixhtmlminbug', 'htmlmin has a bug', function() {
      grunt.log.writeln('Fixing');
      var fs = require('fs');
      var distPath = "./dist/index.html";
      var result = fs.readFileSync(distPath, 'utf8').
        replace(/(initial-scale=1)/g, ' $1').
        replace(/(maximum-scale=1;)/g, ' $1 ');
      fs.writeFileSync(distPath, result, 'utf8');
    });


    grunt.registerTask('prep-dist-dir', [
      'coffee',
      'sass',
      'uglify', // minify FE javascript
      'cssmin', // concat FE css
      'haml',   // needs access to minified files
      'htmlmin',// finally, minify html
      'fixhtmlminbug' // html min bug - TODO: pull request
    ]);

    grunt.registerTask('default', [

      // compile frontend source and prep dist dir
      'prep-dist-dir',

      // run all concurrent watchers
      'concurrent:default'

    ]);
  };
}());
