DROP KEYSPACE ello_streams_test;

-- In a real deployment, the replication strategy will be NetworkTopologyStrategy and with a higher rep factor
CREATE KEYSPACE ello_streams_test 
WITH replication = {'class': 'SimpleStrategy', 'replication_factor':'1'};

USE ello_streams_test;

CREATE TABLE stream_activities (
	user_id int,
	stream_id uuid,
	subject_id int, 
	subject_type text,
	posted_at timeuuid,
	updated_at timeuuid,
	kind text,
	originating_user_id int,
	PRIMARY KEY((user_id, stream_id), posted_at) -- PK is a composite partition key with posted_at as a clustering
) WITH CLUSTERING ORDER BY (posted_at DESC);