module Goldberg
  module Environment
    class << self
      def argv
        ARGV
      end

      def system_call_output(command)
        `#{command}`
      end

      def system(command)
        if block_given?
          yield system_call_output(command), $?.success?
          $?.success?
        else
          super(command)
        end
      end

      [:puts, :sleep, :exec].each do |method_name|
        define_method method_name do |args|
          super(args)
        end
      end

      def write_file(path, text)
        File.open(path, 'w'){|f| f.write text}
      end

      def read_file(path)
        result = ''
        f = File.open(path, "r") do |f|
          f.each_line { |line| result << line }
        end
        result
      end
    end
  end
end
