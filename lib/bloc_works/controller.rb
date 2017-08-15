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
      if args.empty?
        args = [:welcome1, {:book => "Eloquent Ruby"}]
      elsif args.length == 1
        args.insert(0, :welcome2)
      end
      puts "args is: #{args}"
      response(create_response_array(*args))
    end

    # def render(locals = {})
    #   if @routing_params["action"].nil?
    #     response(create_response_array("index", locals))
    #   else
    #     response(create_response_array(@routing_params["action"], locals))
    #   end
    # end

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
