require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs << ['specs']
  t.test_files = ['specs/test*.rb'] 
  t.verbose = true
end

desc 'Create a manual test environment in test_env/'
task :test_env do
  mkdir_p 'test_env/'
  Dir.chdir 'test_env/'
  File.open('file1','w+') { |f| f.puts "Hello, test file 1!" }
  File.open('file2','w+') { |f| f.puts "Hello, test file 2!" }
  sh '../rvn init'
end

desc 'Remove the manual test environment in test_env/'
task :clean_test do
  rm_rf 'test_env/'
end
