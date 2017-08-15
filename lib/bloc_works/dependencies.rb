class Object
  def self.const_missing(const)
    begin
      puts "looking for #{BlocWorks.snake_case(const.to_s)}"
      require BlocWorks.snake_case(const.to_s)
      puts "required #{const}"
      controller = Object.const_get(const)
      puts "obtained const #{const}"
      return controller
    rescue LoadError => e
      puts e.message
      puts e.backtrace.inspect
      return nil
    end
  end
end
