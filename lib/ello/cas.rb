require "ello/cas/version"
require "cassandra"
require "logger"

module Ello
	module Cas
		class Core
			def initialize(keyspace: "ello_test")				
				@cluster = Cassandra.cluster(				
					logger: Logger.new($stderr), 
					compression: :lz4,
					hosts: ['127.0.0.1', '127.0.0.2', '127.0.0.3']
				)
				@cluster.connect(keyspace)
			end

			def hosts
				@cluster.each_host.map { |host| host.ip }
			end
		end
	end
end