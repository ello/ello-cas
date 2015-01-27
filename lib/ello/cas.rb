require "ello/cas/version"
require "cassandra"
require "logger"

module Ello
	module Cas
		class Core
			def initialize(keyspace: "ello_test")				
				@@cluster = Cassandra.cluster(				
					logger: Logger.new($stderr), 
					compression: :lz4,
					hosts: ['127.0.0.1', '127.0.0.2', '127.0.0.3']
				)
				@session = @@cluster.connect(keyspace)

				@friends_insert = @session.prepare(
					"INSERT INTO ello_test.friends_activities(user_id, subject_id, subject_type, posted_at, updated_at, kind, originating_user_id) " \
					"VALUES (?,?,?,now(),now(),?,?)"
				)

				@friends_select = @session.prepare(
					"SELECT subject_id, subject_type, posted_at, kind, originating_user_id " \
					"FROM ello_test.friends_activities " \
					"WHERE user_id = ? LIMIT 10"
				)
			end

			def hosts
				@@cluster.each_host.map { |host| host.ip }
			end

			def friends_insert(user_id, subject_id, subject_type, kind, originating_user_id)
				@session.execute(@friends_insert, user_id, subject_id, subject_type, kind, originating_user_id)
			end

			def friends_activities(user_id)
				@session.execute(@friends_select, user_id)
			end

		end
	end
end