Gem::Specification.new do |s|
  s.name = 'itimer'
  s.version = '9'

  s.authors = ['Nate Mueller', 'Peter Sanford']
  s.summary = 'Timeout replacement using POSIX interval timers'
  s.description = 'Drop-in replacement for stdlib Timeout that uses POSIX interval timers instead of threads.  Not as portable but much lighter weight.  Also includes low-level wrappers for setitimer and getitimer.'
  s.email = 'hackers@nearbuysystems.com'
  s.homepage = 'http://github.com/nearbuy/ruby-itimer'

  s.extensions = 'ext/extconf.rb'
  s.files = ['README.md', 'Rakefile', 'lib/itimer.rb', 'lib/itimer/compat.rb', 'test/itimer.rb', 'ext/extconf.rb', 'ext/itimer_native.c']

  s.required_ruby_version = '>= 1.9.2'
  s.add_development_dependency 'rake-compiler', '~> 0.8.0'
end
