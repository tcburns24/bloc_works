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
      else
        my_action = controller_and_action(env)
        unless my_action[0].nil?
          controller = my_action[0].new(env)
          puts "controller is '#{controller}' and action is #{my_action[1]}"
          puts "does controller respond to action? #{controller.respond_to?(my_action[1])}"
          if controller && controller.respond_to?(my_action[1])
            body = controller.send(my_action[1])
            return [200, {'Content-Type' => 'text/html'}, [body]]
          end
        end
      end
      return [404, {'Content-Type' => 'text/html'}, ["Check your controller and action in the URL"]]
    end
  end
end
