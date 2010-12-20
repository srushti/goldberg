module Goldberg
  module Environment
    class << self
      def argv
        ARGV
      end

      def system(command)
        super(command)
      end
    end
  end
end
