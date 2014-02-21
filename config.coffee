exports.config =
  # See http://brunch.io/#documentation for docs.
  files:
    stylesheets:
      joinTo: 'stylesheets/app.css'
      
    javascripts:
      joinTo: 'javascripts/app.js'
      order:
        before: [
          'vendor/scripts/jquery-1.10.2.js'
          'vendor/scripts/underscore.js'
          'vendor/scripts/select2.js'          
        ]
        after: [
          'vendor/scripts/facetedsearch.js'          
          'vendor/scripts/nomina.data.js'
          'vendor/scripts/nomina.js'
        ]

    templates:
      joinTo: 
      	'js/templates.js': /.+\.jade$/

  imageoptimizer:
    smushit: false # if false it use jpegtran and optipng, if set to true it will use smushit
    path: 'img'

  plugins:
    jade:
      options:          # can be added all the supported jade options
        pretty: yes     # Adds pretty-indentation whitespaces to output (false by default)
    static_jade:                        # all optionals
      #extension:  ".jade"        # static-compile each file with this extension in `assets`
      path:       [ /app/ ]  # static-compile each file in this directories
      #asset:      "app/jade_asset"      # specify the compilation output
