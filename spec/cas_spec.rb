require 'spec_helper'

module Ello
	module Cas
		describe Core do 
			subject { Core.new(keyspace: nil) }

			describe '#hosts' do 
				let(:output) { subject.hosts }
				it 'should return the localhost host' do
					expect(output).to include('127.0.0.1')
				end
			end
		end
	end
end