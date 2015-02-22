require "ello/cas/version"
require "cassandra"
require "logger"

module Ello
	module Cas
		class Core
			def initialize(keyspace: "ello_streams_test")
				@logger = Logger.new($stderr)
				@@cluster = Cassandra.cluster(				
					logger: @logger, 
					compression: :lz4,
					hosts: ['127.0.0.1', '127.0.0.2', '127.0.0.3']
				)
				@session = @@cluster.connect(keyspace)

				@activities_insert = @session.prepare(
					"INSERT INTO stream_activities(user_id, stream_id, subject_id, subject_type, posted_at, updated_at, kind, originating_user_id) " \
					"VALUES (?,?,?,?,?,?,?,?)"
				)

				@activities_select = @session.prepare(
					"SELECT subject_id, subject_type, posted_at, kind, originating_user_id " \
					"FROM stream_activities " \
					"WHERE user_id = ? and stream_id = ? LIMIT 10"
				)

				#Not threadsafe, don't use a class level instance
				@uuid = Cassandra::Uuid::Generator.new				
			end

			def hosts
				@logger.debug "#hosts"
				@@cluster.each_host.map { |host| host.ip }
			end

			def activities_insert(user_id, stream_id, subject_id, subject_type, posted_at=@uuid.now, updated_at=@uuid.now, kind, originating_user_id)
				@logger.debug "#activites_insert(#{user_id}, #{stream_id}, #{subject_id}, #{subject_type}, #{posted_at}, #{updated_at}, #{kind}, #{originating_user_id})"
				@session.execute(@activities_insert, arguments: [user_id, stream_id, subject_id, subject_type, posted_at, updated_at, kind, originating_user_id])
			end

			def activities_select(user_id, stream_id)
				@logger.debug "#activites_select(#{user_id}, #{stream_id})"
				@session.execute(@activities_select, arguments: [user_id, stream_id])
			end

		end
	end
end