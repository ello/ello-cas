require "ello/cas/version"
require "cassandra"
require "logger"

module Ello
	module Cas
		class Cas
			def initialize
				@cluster = Cassandra.cluster(logger: Logger.new($stderr))
			end

			def print_hosts
				@cluster.each_host do |host|
					puts "Host #{host.ip}: id=#{host.id} datacenter=#{host.datacenter} rack=#{host.rack}"
				end
			end
		end
	end
end