Gem::Specification.new do |s|
  s.name = 'itimer'
  s.version = '1'

  s.authors = ['Nate Mueller']
  s.date = '2012-08-10'
  s.summary = 'Simple wrapper around POSIX interval timer functions'
  s.description = 'Simple wrapper around POSIX interval timer functions'
  s.email = 'hackers@nearbuysystems.com'
  s.homepage = 'http://github.com/nearbuy/itimer'

  s.extensions = 'ext/extconf.rb'

  s.required_ruby_version = '>= 1.9.2'
  s.add_development_dependency 'rake-compiler', '~> 0.8.0'
end
