module Env
  class << self
    def [](variable_name)
      ENV[variable_name]
    end
  end
end

