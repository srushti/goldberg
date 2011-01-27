module Goldberg
  module Environment
    class << self
      def argv
        ARGV
      end

      def system_call_output(command)
        `#{command}`
      end

      [:system, :puts, :sleep].each do |method_name|
        define_method method_name do |args|
          super(args)
        end
      end

      def write_file(path, text)
        File.open(path, 'w'){|f| f.write text}
      end

      def read_file(path)
        data = ''
        f = File.open(path, "r") do |f|
          f.each_line do |line|
            data += "#{line}\n"
          end
        end
        data
      end
    end
  end
end
