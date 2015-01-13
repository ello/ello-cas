require 'spec_helper'

module Ello
	module Cas
		describe Cas do 
			subject { Cas.new }

			describe '#print_hosts' do 
				it 'does stuff' do
					subject.print_hosts
				end
			end
		end
	end
end