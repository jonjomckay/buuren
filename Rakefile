# encoding: utf-8

require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "buuren"
  gem.homepage = "http://github.com/jonjomckay/buuren"
  gem.license = "MIT"
  gem.summary = %Q{Playback section of jukebox app}
  gem.description = %Q{Playback section of jukebox app}
  gem.email = "jonjo@jonjomckay.com"
  gem.authors = ["Jonjo McKay"]
  # dependencies defined in Gemfile
end
Jeweler::RubygemsDotOrgTasks.new

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

begin
  require 'simplecov'
  desc "Execute tests with coverage report"
  task :rcov do
    ENV["COVERAGE"] = "true"
    Rake::Task["test"].execute
  end
rescue LoadError
end


require 'rdoc/task'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "buuren #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
