require 'spec_helper'

describe GlobalConfig do
  before :each do
    GlobalConfig.class_eval do
      @config_hash = nil
    end
  end

  context "default values" do
    it "returns frequency to 20 seconds" do
      File.should_receive(:exists?).with("#{Rails.root}/config/goldberg.yml").and_return(false)
      GlobalConfig.frequency.should eq(20)
    end
  end

  context "yml file exists" do
    it "returns the frequency from yml file" do
      File.should_receive(:exists?).with("#{Rails.root}/config/goldberg.yml").and_return(true)
      YAML.should_receive(:load_file).with("#{Rails.root}/config/goldberg.yml").and_return({ Rails.env => {"frequency"=>30} })
      GlobalConfig.frequency.should eq(30)
    end
  end

  describe "reading yml file" do
    it "reads the configuration from config/goldberg.yml if available and return configuration for current Rails.env" do
      File.should_receive(:exists?).with("#{Rails.root}/config/goldberg.yml").and_return(true)
      YAML.should_receive(:load_file).with("#{Rails.root}/config/goldberg.yml").and_return({ Rails.env => {"frequency"=>30} })
      GlobalConfig.read_settings_hash.should eq({"frequency"=>30})
    end

    it "returns an empty hash if config/goldberg.yml is not available" do
      File.should_receive(:exists?).with("#{Rails.root}/config/goldberg.yml").and_return(false)
      GlobalConfig.read_settings_hash.should eq({})
    end
  end
end