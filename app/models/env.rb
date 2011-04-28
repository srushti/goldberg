module Env
  class << self
    def [](variable_name)
      ENV[variable_name]
    end

    def []=(variable_name, value)
      ENV[variable_name] = value
    end
  end
end

