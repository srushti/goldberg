module Bundle
  class << self
    def check_and_install
      'bundle check --no-color || bundle install --no-color'
    end
  end
end
