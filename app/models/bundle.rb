module Bundle
  class << self
    def check_and_install
      'bundle check || bundle install'
    end
  end
end
