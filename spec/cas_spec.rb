require 'spec_helper'

module Ello
	module Cas
		describe Core do 
			# Could use SecureRandom#uuid + Cassandra::Uuid#new but this will make timeuuid's easier down the road
			UUID_GENERATOR = Cassandra::Uuid::Generator.new

			let(:friends_stream_id) { UUID_GENERATOR.uuid }
			let(:noise_stream_id) { UUID_GENERATOR.uuid }
			let(:notifications_stream_id) { UUID_GENERATOR.uuid }

			subject { Core.new(keyspace: 'ello_streams_test') }

			describe '#hosts' do 
				let(:output) { subject.hosts }
				it 'should return the localhost host' do
					expect(output.length).to be(3)
					expect(output).to include('127.0.0.1')
				end				
			end

			describe '#activities_insert' do
				let(:user_id) { 15 }
				let(:originating) { 25 }
				before {
					subject.activities_insert(user_id, friends_stream_id, 100, "Test Type", "Test Kind", originating)
				}
				let(:output) { subject.activities_select(user_id, friends_stream_id).first }

				it 'should return the record inserted' do 		
					expect(output['originating_user_id']).to eq(originating)
				end

				it 'should have distinct timeuuids for different inserted records' do
					subject.activities_insert(user_id, friends_stream_id, 101, "Test Type", "Test Kind", originating)
					posted_times = subject.activities_select(user_id, friends_stream_id).map{|a| a['posted_at']};
					expect(posted_times.uniq.length).to eq(2)					
				end

				it 'should honor the time passed' do
					old_date = Time.new(2015, 1, 2)
					old_date_uuid = UUID_GENERATOR.at(old_date)
					subject.activities_insert(user_id, friends_stream_id, 101, "Test Type", old_date_uuid, old_date_uuid, "Test Kind", originating)

					posted_times = subject.activities_select(user_id, friends_stream_id).map{|a| a['posted_at']};

					#Rounding is necessary here, as timeuuid introduces some fuzz at the nanosecond level when converting to/from
					expect(posted_times.last.to_time.utc.round).to eq(old_date.utc.round)
				end
			end

			describe '#activities_select_paged' do
				let(:user_id) { 15 }
				let(:originating) { 25 }
				
				let(:new_date) { Time.new(2015, 2, 2) }
				let(:new_date_uuid) { UUID_GENERATOR.at(new_date) }

				let(:old_date) { Time.new(2015, 1, 2) }
				let(:old_date_uuid) { UUID_GENERATOR.at(old_date) }

				let(:now_uuid) { UUID_GENERATOR.now() }

				before {
					subject.activities_insert(user_id, friends_stream_id, 100, "Test Type", new_date_uuid, new_date_uuid, "Test Kind", originating)
					subject.activities_insert(user_id, friends_stream_id, 100, "Test Type", now_uuid, now_uuid, "Test Kind", originating)
					subject.activities_insert(user_id, friends_stream_id, 101, "Test Type", old_date_uuid, old_date_uuid, "Test Kind", originating)
				}

				it 'should return 3 results when no time is passed' do
					results = subject.activities_select(user_id, friends_stream_id)
					expect(results.length).to eq(3)
				end

				it 'should return older results when now is passed' do
					results = subject.activities_select_paged(user_id, friends_stream_id, now_uuid)

					expect(results.length).to eq(2)
				end

				it 'should honor passed page size' do
					results = subject.activities_select_paged(user_id, friends_stream_id, now_uuid, 1)

					expect(results.length).to eq(1)
					expect(results.first['posted_at'].to_time.round).to eq(new_date.round)
				end

				it 'should return old results when new date passed' do
					results = subject.activities_select_paged(user_id, friends_stream_id, new_date_uuid)
					posted_times = results.map{|a| a['posted_at']};

					expect(posted_times.uniq.length).to eq(1)
					expect(posted_times.last.to_time.round).to eq(old_date.round)
				end
			end
		end
	end
end