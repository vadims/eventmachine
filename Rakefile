#!/usr/bin/env rake
#--
# Ruby/EventMachine
#   http://rubyeventmachine.com
#   Copyright (C) 2006-07 by Francis Cianfrocca
#
#   This program is copyrighted free software. You may use it under
#   the terms of either the GPL or Ruby's License. See the file
#   COPYING in the EventMachine distribution for full licensing
#   information.
#
# $Id$
#++

### OLD RAKE: ###
# # The tasks and external gemspecs we used to generate binary gems are now
# # obsolete. Use Patrick Hurley's gembuilder to build binary gems for any
# # desired platform.
# # To build a binary gem on Win32, ensure that the include and lib paths
# # both contain the proper references to OPENSSL. Use the static version
# # of the libraries, not the dynamic, otherwise we expose the user to a
# # runtime dependency.
# 
# # To build a binary gem for win32, first build rubyeventmachine.so
# # using VC6 outside of the build tree (the normal way: ruby extconf.rb,
# # and then nmake). Then copy rubyeventmachine.so into the lib directory,
# # and run rake gemwin32.
#

require 'rubygems'  unless defined?(Gem)
require 'rake'      unless defined?(Rake)
require 'rake/gempackagetask'

Package = false # Build zips and tarballs?
Dir.glob('tasks/*.rake').each { |r| Rake.application.add_import r }

# e.g. rake EVENTMACHINE_LIBRARY=java for forcing java build tasks as defaults!
$eventmachine_library = :java if RUBY_PLATFORM =~ /java/ || ENV['EVENTMACHINE_LIBRARY'] == 'java'
$eventmachine_library = :pure_ruby if ENV['EVENTMACHINE_LIBRARY'] == 'pure_ruby'

# If running under rubygems...
__DIR__ ||= File.expand_path(File.dirname(__FILE__))
if Gem.path.any? {|path| %r(^#{Regexp.escape path}) =~ __DIR__}
  task :default => :gem_build
else
  desc "Build gemspec, then build eventmachine, then run tests."
  task :default => [:gemspec, :build, :test]
end

desc ":default build when running under rubygems."
task :gem_build => :build

desc "Build extension (or EVENTMACHIINE_LIBRARY) and place in lib"
build_task = 'ext:build'
build_task = 'java:build' if $eventmachine_library == :java
build_task = :dummy_build if $eventmachine_library == :pure_ruby
task :build => build_task do |t|
  Dir.glob('{ext,java/src}/*.{so,bundle,dll,jar}').each do |f|
    mv f, "lib"
  end
end

task :dummy_build

# Basic clean definition, this is enhanced by imports aswell.
task :clean do
  chdir 'ext' do
    sh 'make clean' if test ?e, 'Makefile'
  end
  Dir.glob('**/Makefile').each { |file| rm file }
  Dir.glob('**/*.{o,so,bundle,class,jar,dll,log}').each { |file| rm file }
end

Spec = Gem::Specification.new do |s|
  s.name              = "eventmachine"
  s.summary           = "Ruby/EventMachine library"
  s.platform          = Gem::Platform::RUBY

  s.has_rdoc          = true
  s.rdoc_options      = %w(--title EventMachine --main docs/README --line-numbers)
  s.extra_rdoc_files  = Dir['docs/*']

  s.files             = %w(Rakefile) + Dir["{bin,tests,lib,ext,java,tasks}/**/*"]

  s.require_path      = 'lib'

  s.test_file         = "tests/testem.rb"
  s.extensions        = "Rakefile"

  s.author            = "Francis Cianfrocca"
  s.email             = "garbagecat10@gmail.com"
  s.rubyforge_project = 'eventmachine'
  s.homepage          = "http://rubyeventmachine.com"

  # Pulled in from readme, as code to pull from readme was not working!
  # Might be worth removing as no one seems to use gem info anyway.
  s.description = <<-EOD
EventMachine implements a fast, single-threaded engine for arbitrary network
communications. It's extremely easy to use in Ruby. EventMachine wraps all
interactions with IP sockets, allowing programs to concentrate on the
implementation of network protocols. It can be used to create both network
servers and clients. To create a server or client, a Ruby program only needs
to specify the IP address and port, and provide a Module that implements the
communications protocol. Implementations of several standard network protocols
are provided with the package, primarily to serve as examples. The real goal
of EventMachine is to enable programs to easily interface with other programs
using TCP/IP, especially if custom protocols are required.
  EOD

  require 'lib/eventmachine_version'
  s.version = EventMachine::VERSION
end

namespace :ext do
  desc "Build C++ extension"
  task :build => [:clean, :make]
  
  desc "make extension"
  task :make => [:makefile] do
    chdir 'ext' do
      sh 'make'
    end
  end

  desc 'Compile the makefile'
  task :makefile do |t|
    chdir 'ext' do
      ruby 'extconf.rb'
    end
  end
end
  
namespace :java do
  # This task creates the JRuby JAR file and leaves it in the lib directory.
  # This step is required before executing the jgem task.
  desc "Build java extension"
  task :build => [:jar] do |t|
    chdir('java/src') do
      mv 'em_reactor.jar', '../../lib/em_reactor.jar'
    end
  end
  
  desc "compile .java to .class"
  task :compile do
    chdir('java/src') do
      sh 'javac com/rubyeventmachine/*.java'
    end
  end
  
  desc "compile .classes to .jar"
  task :jar => [:compile] do
    chdir('java/src') do
      sh "jar -cf em_reactor.jar com/rubyeventmachine/*.class"
    end
  end
end

task :gemspec => :clean do
  open("eventmachine.gemspec", 'w') { |f| f.write Spec.to_ruby }
end