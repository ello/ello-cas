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

			describe '#friends_activities' do
				let(:user_id) { 15 }
				let(:originating) { 25 }
				before {
					subject.activities_insert(user_id, friends_stream_id, 100, "Test Type", "Test Kind", originating)
				}
				let(:output) { subject.activities_select(user_id, friends_stream_id).first }

				it 'should return the record inserted' do 		
					expect(output['originating_user_id']).to eq(originating)
				end
			end
		end
	end
end