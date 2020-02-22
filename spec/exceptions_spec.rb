module Keka
  RSpec.describe Halt do
    describe 'initialization' do
      it 'is initialized with a Keka::Result' do
        begin
          result = Result.new(true, nil)
          raise described_class.new(result)
        rescue described_class => e
          expect(e.result).to eq(result)
        end
      end
    end
  end
end
