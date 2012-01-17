GITHUB_CONFIG = YAML.load_file("#{::Rails.root.to_s}/config/github.yml")[::Rails.env.to_s]
