# *~@~*~@~*~@~*~@*@~*~@~*~@~*~@~*~@~*
# ASK CYLE: what should this file look like?
# *~@~*~@~*~@~*~@*@~*~@~*~@~*~@~*~@~*

require "bloc_works/version"
require "bloc_works/controller"
require "bloc_works/dependencies"
require "bloc_works/router"
require "bloc_works/utility"

module BlocWorks
  class Application
    def call(env)
      # [status code, {header}, [body]]
      # if the request is for a favicon
      #   return the 404 format (see fav_icon)
      # otherwise
      #   assume /controller/action and use controller_and_action to parse PATH_INFO
      #   then, execute the action and return the result
      if env['PATH_INFO'] == '/favicon.ico'
        return [404, {'Content-Type' => 'text/html'}, []]
      end
      rack_app = get_rack_app(env)
      rack_app.call(env)
    end
  end
end
