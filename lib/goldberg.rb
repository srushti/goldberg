require 'sinatra'
require 'git'

module Goldberg
end

['/goldberg/**/*.rb'].each{|directory|
  Dir["#{File.expand_path(File.dirname(__FILE__) + directory)}"].each { |file|
    require file
  }
}

get '/' do
  'Hello world!'
end

