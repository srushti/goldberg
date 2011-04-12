class GlobalConfig

  DEFAULT_CONFIG = {'frequency' => 10}

  class << self
    def frequency
      config_hash['frequency']
    end

    def config_hash
      @config_hash ||= DEFAULT_CONFIG.merge(read_settings_hash)
    end

    def read_settings_hash
      if File.exists?("#{Rails.root}/config/goldberg.yml")
        YAML::load_file("#{Rails.root}/config/goldberg.yml")[Rails.env]
      else
        {}
      end
    end
  end


end