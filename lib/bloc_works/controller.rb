require "erubis"

module BlocWorks
  class Controller
    def request
      @request ||= Rack::Request.new(@env)
    end

    def params
      request.params
    end

    def initialize(env)
      @env = env
      @routing_params = {}
    end

    def dispatch(action, routing_params = {})
      @routing_params = routing_params
      puts "executing action"
      text = self.send(action)
      if has_response?
        puts "getting generated response"
        rack_response = get_response
        puts "creating triple from response"
        [rack_response.status, rack_response.header, [rack_response.body].flatten]
      else
        puts "creating triple from returned text"
        [200, {'Content-Type' => 'text/html'}, [text].flatten]
      end
    end

    def self.action(action, response = {})
      puts "creating proc"
      proc { |env| puts "creating controller to dispatch"; self.new(env).dispatch(action, response) }
    end

    def response(text, status = 200, headers = {})
      raise "Cannot respond multiple times" unless @response.nil?
      @response = Rack::Response.new([text].flatten, status, headers)
    end

    def render(*args)
      puts "args was: #{args}"

      # view := args[0] (if given) OR action_name
      # locals := args[0] (if given with no view) OR args[1] (if given after view) OR {} (if not given)

      puts "action: #{@routing_params["action"]}"

      if args.length == 0
        view = @routing_params["action"]
        locals = {}
      elsif (args.length == 1) && (args[0].class == Symbol)
        view = args[0]
        locals = {}
      elsif (args.length == 1) && (args[0].class == Hash)
        view = @routing_params["action"]
        locals = args[0]
      elsif args.length > 1
        view = args[0]
        locals = args[1]
      end

      # CASE 1:
      #   render => args := []
      #   view := action_name (which is @routing_params["action"])
      #   locals := {}
      # CASE 2:
      #   render :arbitrary_view_name => args := [:arbitrary_view_name]
      #   view := :arbitrary_view_name (which is args[0])
      #   locals := {}
      # CASE 3:
      #   render some: "data" => args := [{some: "data"}]
      #   view := action_name (which is @routing_params["action"])
      #   locals := {some: "data"} (which is args[0])
      # CASE 4:
      #   render :arbitrary_view_name, some: "data" => args := [:arbitrary_view_name, {some: "data"}]
      #   view := :arbitrary_view_name (which is args[0])
      #   locals := {some: "data"} (which is args[1])

      response(create_response_array(view, locals))
    end

    def get_response
      @response
    end

    def has_response?
      !@response.nil?
    end

    def create_response_array(view, locals = {})
      filename = File.join("app", "views", controller_dir, "#{view}.html.erb")
      template = File.read(filename)

      puts "#{locals.class}"
      locals[:env] = @env

      # Add in instance variables (including `@` before names (e.g. @books))

      self.instance_variables.each do |var_name|
        locals[var_name] = self.instance_variable_get(var_name)
      end

      eruby = Erubis::Eruby.new(template)
      eruby.result(locals)
    end

    def controller_dir
      klass = self.class.to_s
      klass.slice!("Controller")
      BlocWorks.snake_case(klass)
    end

    def params
      req = Rack::Request.new(@env)
      req.params
    end

    # checkpoint 4 instructs `def params` to look like:
      # def params
      #   request.params.merge(@routing_params)
      # end
  end
end
