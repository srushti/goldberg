module Goldberg
  module Environment
    class << self
      def argv
        ARGV
      end

      [:system, :puts, :sleep].each do |method_name|
        define_method method_name do |args|
          super(args)
        end
      end
    end
  end
end
