module Goldberg
  class Logger
    ['info', 'debug', 'warn', 'error', 'fatal'].each do |method_name|
      define_method method_name do |message|
        Environment.puts message
      end
    end
  end
end
