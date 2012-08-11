require 'rake/testtask'
require 'rake/extensiontask'

Rake::ExtensionTask.new('itimer') do |ext|
  ext.ext_dir = 'ext'
end

Rake::TestTask.new do |t|
  t.test_files = FileList['test/*.rb']
end

task :test => :compile
