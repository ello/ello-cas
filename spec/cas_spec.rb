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
		end
	end
end