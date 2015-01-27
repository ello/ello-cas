require 'rspec/core/rake_task'

desc "Runs the cql file passed as the {file} arg"
task :cas, :file do |t, args|
	puts "Running cqlsh -f #{args[:file]}"

	output = `cqlsh -f #{args[:file]}`

	puts "#{output}" if !output.empty?
	puts "Completed"
end