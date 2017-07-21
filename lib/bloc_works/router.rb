module BlocWorks
  class Application
    def controller_and_action(env)
      _, controller, action, _ = env["PATH_INFO"].split("/", 4)
      controller = controller.capitalize
      controller = "#{controller}Controller"

      puts "controller name is #{controller}"

      [Object.const_get(controller), action]
    end

    def fav_icon(env)
      if env['PATH_INFO'] == '/favicon.ico'
        return [404, {'Content-Type' => 'text/html'}, []]
      end
    end

    def route(&block)
      @router ||= Router.new
      @router.instance_eval(&block)
    end

    def get_rack_app(env)
      if @router.nil?
        raise "No routes defined"
      end

      @router.look_up_url(env["PATH_INFO"])
    end
  end

  class Router 
    # assignment: implement `redirect`:
    # get '/old/path', to: rediirect('/new/path', status: 302)
    def redirect(controller, action)
      get_destination("#{controller}##{action}")
    end

    # assignment 4:

    # ATTEMPT 1:
    # def to_view(action_name)
    #   @controller = self.controller
    #   return @controller.redirect(self, action_name)
    # end

    # ATTEMPT 2:
    def to_view(action_name)
      if action_name
        get_destination("#{controller}##{action_name}")
      else
        return [404, {'Content-Type' => 'text/html'}, []]
      end
    end

    # Assignment 4: adding `resources`:
    def make_resourceful(controller)
      all_routes = [
        "get '/#{controller}', to: #{controller}#index'"
        "get '/#{controller}', to: #{controller}#new'"
        "post '/#{controller}', to: #{controller}#create'"
        "get '/#{controller}', to: #{controller}#show'",
        "get '/#{controller}', to: #{controller}#edit'"
        "put '/#{controller}', to: #{controller}#update'"
        "delete '/#{controller}', to: #{controller}#destroy'"
      ]
      @controller = self.controller
      if @controller.route.include?('resources')
        for route in all_routes
          @controller.router += route
        end
      end
    end

    def initialize
      @rules = []
    end

    def map(url, *args)
      options = {}
      options = args.pop if args[-1].is_a?(Hash)
      options[:default] ||= {}

      destination = nil
      destination = args.pop if args.size > 0
      raise "Too many args!" if args.size > 0

      parts = url.split("/")
      parts.reject! { |part| part.empty? }

      vars, regex_parts = [], []

      parts.each do |part|
        case part[0]
        when ":"
          vars << part[1..-1]
          regex_parts << "([a-zA-Z0-9]+)"
        when "*"
          vars << part[1..-1]
          regex_parts << "(.*)"
        else
          regex_parts << part
        end
      end

      regex = regex_parts.join("/")
      @rules.push({ regex: Regexp.new("^/#{regex}$"),
                    vars: vars, destination: destination,
                    options: options })
    end

    def look_up_url(url)
      @rules.each do |rule|
        rule_match = rule[:regex].match(url)

        if rule_match
          options = rule[:options]
          params = options[:default].dup

          rule[:vars].each_with_index do |var, index|
            params[var] = rule_match.captures[index]
          end

          if rule[:destination]
            return get_destination(rule[:destination], params)
          else
            controller = params["controller"]
            action = params["action"]
            return get_destination("#{controller}##{action}", params)
          end
        end
      end
    end

    def get_destination(destination, routing_params = {})
      if destination.respond_to?(:call)
        return destination
      end
      if destination =~ /^([^#]+)#([^#]+)$/
        name = $1.capitalize
        controller = Object.const_get("#{name}Controller")
        return controller.action($2, routing_params)
      end
      raise "Destination not found: #{destination}"
    end
  end
end

# resources :patients

# =

# get '/patients/:id', to: 'patients#show'
# destroy '/patients/:id', to: 'patients#destroy'
# post '/patients/:id', to: 'patients#update'
