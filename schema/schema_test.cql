DROP KEYSPACE ello_test;

CREATE KEYSPACE ello_test 
WITH replication = {'class': 'SimpleStrategy', 'replication_factor':'1'};

USE ello_test;

CREATE TABLE friends_activities (
	user_id int,
	subject_id int, 
	subject_type text,
	posted_at timeuuid,
	updated_at timestamp,
	kind text,
	originating_user_id int,
	PRIMARY KEY(user_id, posted_at)
) WITH CLUSTERING ORDER BY (posted_at DESC);

CREATE TABLE noise_activities (
	user_id int,
	subject_id int, 
	subject_type text,
	posted_at timeuuid,
	updated_at timestamp,
	-- currently only one type of noise, can eliminate column?
	kind text,
	originating_user_id int,
	PRIMARY KEY(user_id, posted_at)
) WITH CLUSTERING ORDER BY (posted_at DESC);

CREATE TABLE notifications_activities (
	user_id int,
	subject_id int, 
	subject_type text,
	posted_at timeuuid,
	updated_at timestamp,
	kind text,
	originating_user_id int,
	PRIMARY KEY(user_id, posted_at)
) WITH CLUSTERING ORDER BY (posted_at DESC);