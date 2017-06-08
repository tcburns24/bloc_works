require "bloc_works/version"

module BlocWorks
  class Application
    def call(env)
      # [status code, {header}, [body]]
      [200, {'Content-Type' => 'text/html'}, ["Hello Blocheads!"]]
    end
  end
end
