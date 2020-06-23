#!/usr/bin/env rake
# frozen_string_literal: true

require 'rake/clean'
require 'securerandom'
CLOBBER.include 'pkg'

require 'bundler/gem_helper'
Bundler::GemHelper.install_tasks name: 'eyes_core'
Bundler::GemHelper.install_tasks name: 'eyes_images'
Bundler::GemHelper.install_tasks name: 'eyes_selenium'
Bundler::GemHelper.install_tasks name: 'eyes_calabash'
Bundler::GemHelper.install_tasks name: 'eyes_capybara'
Bundler::GemHelper.install_tasks name: 'eyes_appium'

unless ENV['BUILD_ONLY'] && !ENV['BUILD_ONLY'].empty?
  require 'rspec/core/rake_task'
  require 'webdrivers'
  load 'webdrivers/Rakefile'
  require 'parallel_tests/tasks'
  RSpec::Core::RakeTask.new(:spec)
  RSpec::Core::RakeTask.new(:spec_selenium) do |t|
    t.pattern = 'spec/integration/*_spec.rb'
    t.rspec_opts = '--tag selenium'
  end

  # RSpec::Core::RakeTask.new(:spec_vg) do |t|
  #   t.pattern = 'spec/integration/*_spec.rb'
  #   t.rspec_opts = '--tag selenium'
  # end

  RSpec::Core::RakeTask.new(:spec_vg) do |t|
    t.pattern = 'spec/integration/*_spec.rb'
    t.rspec_opts = '--tag visual_grid'
  end

  task :set_batch_info do
    string = ENV['TRAVIS_COMMIT'] ? ENV['TRAVIS_COMMIT'] + ENV['TRAVIS_RUBY_VERSION'] : SecureRandom.hex
    batch_id = `(java UUIDFromString #{string})`
    # next if ENV['APPLITOOLS_BATCH_ID'] && !ENV['APPLITOOLS_BATCH_ID'].empty?
    ENV['APPLITOOLS_BATCH_ID'] = batch_id unless ENV['APPLITOOLS_BATCH_ID'] && !ENV['APPLITOOLS_BATCH_ID'].empty?
    ENV['APPLITOOLS_BATCH_NAME'] = "Eyes Ruby SDK(#{RUBY_VERSION})"
  end
  task :check do
    puts "Batch ID: #{ENV['APPLITOOLS_BATCH_ID']}"
    puts "Batch NAME: #{ENV['APPLITOOLS_BATCH_NAME']}"
  end
  # task rspec_travis: [:spec_selenium]
  # task visual_tests: [:set_batch_info, :check, :spec_selenium]
  task :default => :parallel_travis
  task :parallel_travis => ['webdrivers:chromedriver:update', :set_batch_info, :check] do
    # Rake::Task['parallel:spec'.to_sym].invoke(4, 'spec\/integration\/(?!old_tests)', ' --tag=selenium')
    sh('bundle exec parallel_rspec -n 4 -- --tag selenium -- spec/integration/*_spec.rb')
  end

  task :travis_selenium => ['webdrivers:chromedriver:update', :set_batch_info, :check] do
    sh('bundle exec parallel_rspec -n 4 -- --tag selenium -- spec/integration/*_spec.rb')
  end

  task :travis_vg => ['webdrivers:chromedriver:update', :set_batch_info, :check] do
    sh('bundle exec parallel_rspec -n 1 -- --tag visual_grid -- spec/integration/*_spec.rb')
  end

  namespace :unit_tests do
    RSpec::Core::RakeTask.new(:core) do |t|
      t.pattern = 'spec/core'
    end

    RSpec::Core::RakeTask.new(:visual_grid) do |t|
      t.pattern = 'spec/visual_grid'
    end

    RSpec::Core::RakeTask.new(:regression) do |t|
      t.pattern = 'spec/regression'
    end

    task :travis => [:regression, :core, :visual_grid]
  end


  # case ENV['END_TO_END_TESTS']
  # when 'false'
  #   require 'rspec/core/rake_task'
  #   require 'rubocop/rake_task'
  #   RuboCop::RakeTask.new
  #
  #   RSpec::Core::RakeTask.new(:spec) do |t|
  #     t.rspec_opts = '--tag ~integration'
  #   end
  #
  #   if Gem::Version.new(RUBY_VERSION) < Gem::Version.new('2.0.0')
  #     task perform_tests: [:spec]
  #   else
  #     task perform_tests: [:rubocop, :spec]
  #   end
  #   task :default => :perform_tests
  # when 'selenium'
  #   require 'rspec/core/rake_task'
  #   require 'rubocop/rake_task'
  #
  #   browsers = %w(chrome firefox)
  #   browsers.delete(ENV['TEST_IN_BROWSER'])
  #   options = ["api:#{ENV['TEST_API']}"] + browsers.map { |b| "~browser:#{b}" }
  #   RSpec::Core::RakeTask.new(:spec) do |t|
  #     t.rspec_opts = '--tag ~integration'
  #   end
  #
  #   desc 'Checks if necessary environment variables are set'
  #   task :check_integration_test_required_variables do
  #     raise StandardError, 'Please set TEST_IN_BROWSER environment variable' unless
  #         ENV['TEST_IN_BROWSER'] && !ENV['TEST_IN_BROWSER'].empty?
  #     raise StandardError, 'Please set TEST_API environment variable' unless ENV['TEST_API'] && !ENV['TEST_API'].empty?
  #   end
  #
  #   RSpec::Core::RakeTask.new(spec_integration: [:check_integration_test_required_variables]) do |t|
  #     t.rspec_opts = options.map { |o| '--tag ' + o }.join(' ')
  #   end
  #
  #   RSpec::Core::RakeTask.new(:spec_integration_all) do |t|
  #     t.rspec_opts = '--tag integration'
  #   end
  #
  #   task :default => :spec_integration
  # when 'capybara'
  #   require 'rspec/core/rake_task'
  #   RSpec::Core::RakeTask.new(:spec_integration) do |t|
  #     t.rspec_opts = '--tag capybara'
  #     t.pattern = 'spec/integration/eyes_capybara_spec.rb'
  #   end
  #   task :default => :spec_integration
  # when 'overflow'
  #   require 'rspec/core/rake_task'
  #   RSpec::Core::RakeTask.new(:spec_integration) do |t|
  #     t.rspec_opts = '--tag overflow'
  #     t.pattern = 'spec/integration/eyes_overflow_spec.rb'
  #   end
  #   task :default => :spec_integration
  # end
end
