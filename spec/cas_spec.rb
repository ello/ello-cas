require 'spec_helper'

module Ello
	module Cas
		describe Core do 
			subject { Core.new(keyspace: nil) }

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
					subject.friends_insert(user_id, 100, "Test Type", "Test Kind", originating)
				}
				let(:output) { subject.friends_activities(user_id).first }

				it 'should return the record inserted' do 
					expect(output['originating_user_id']).to eq(originating)
					expect(output).to_not be_nil
				end
			end
		end
	end
end