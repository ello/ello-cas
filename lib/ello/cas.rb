require "ello/cas/version"
require "cassandra"
require "logger"

module Ello
	module Cas
		class Core
			def initialize(keyspace: "test_ello")				
				@cluster = Cassandra.cluster(logger: Logger.new($stderr))
				@cluster.connect(keyspace)
				@cluster.each_keyspace { |ks| puts "#{ks.name}"}
			end

			def hosts
				@cluster.each_host.map { |host| host.ip }
			end
		end
	end
end