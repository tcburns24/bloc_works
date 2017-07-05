require "erubis"

module BlocWorks
  class Controller
    def initialize(env)
      @env = env
    end

    def render(view, locals = {})
      filename = File.join("app", "views", controller_dir, "#{view}.html.erb")
      template = File.read(filename)

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
  end
end
