class Object
  def self.const_missing(const)
    begin
      puts "looking for #{BlocWorks.snake_case(const.to_s)}"
      require BlocWorks.snake_case(const.to_s)
      Object.const_get(const)
    rescue LoadError => e
      puts e.message
      puts e.backtrace.inspect
      return nil
    end
  end
end
