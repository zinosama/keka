module Keka
  RSpec.describe Result do
    describe '#ok?' do
      it { expect(described_class.new(true, nil)).to be_ok }
      it { expect(described_class.new(false, nil)).not_to be_ok }
    end
  end
end
