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

      puts "looking up url"

      @router.look_up_url(env["PATH_INFO"], env["REQUEST_METHOD"])
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

    def initialize
      @rules = []
    end

    def resources(controller_name)
      # GET    /books        => Show all books                          (index)
      # GET    /books/3      => Show book "3"                           (show)
      # GET    /books/new    => Show new book form                      (new)
      # GET    /books/3/edit => Show edit book form for book "3"        (edit)
      # POST   /books        => Create new book (data given in params)  (create)
      # PUT    /books/3      => Update book "3" (data given in params)  (update)
      # DELETE /books/3      => Delete book "3"                         (delete)

      map "/#{controller_name}",          default: { "controller" => controller_name, "action" => "index", "request" => "GET" }
      map "/#{controller_name}/:id",      default: { "controller" => controller_name, "action" => "show", "request" => "GET" }
      map "/#{controller_name}/new",      default: { "controller" => controller_name, "action" => "new", "request" => "GET" }
      map "/#{controller_name}/:id/edit", default: { "controller" => controller_name, "action" => "edit", "request" => "GET" }
      map "/#{controller_name}",          default: { "controller" => controller_name, "action" => "create", "request" => "POST" }
      map "/#{controller_name}/:id",      default: { "controller" => controller_name, "action" => "update", "request" => "PUT" }
      map "/#{controller_name}/:id",      default: { "controller" => controller_name, "action" => "destroy", "request" => "DELETE" }
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

    def look_up_url(url, request)
      @rules.each do |rule|
        puts "checking rule #{rule}"

        puts "matching url"
        rule_match = rule[:regex].match(url)

        puts "matching request"
        request_match = (rule[:options][:default]["request"]).match(request)

        if rule_match && request_match
          puts "duplicating options"
          options = rule[:options]
          params = options[:default].dup

          puts "copying rule captures"
          rule[:vars].each_with_index do |var, index|
            params[var] = rule_match.captures[index]
          end

          if rule[:destination]
            puts "getting destination from rule destination"
            return get_destination(rule[:destination], params)
          else
            puts "getting destination from controller and action"
            controller = params["controller"]
            action = params["action"]
            return get_destination("#{controller}##{action}", params)
          end
        end
      end
    end

    def get_destination(destination, routing_params = {})
      if destination.respond_to?(:call)
        puts "returing destination with 'call'"
        return destination
      end
      if destination =~ /^([^#]+)#([^#]+)$/
        name = $1.capitalize
        controller = Object.const_get("#{name}Controller")
        routing_params["controller"] = $1
        routing_params["action"] = $2
        puts "returning destination from controller.action"
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
