module Goldberg
  class Logger
    ['info', 'debug', 'warn', 'error', 'fatal'].each do |method_name|
      define_method method_name do |message|
        puts message
      end
    end
  end
end
