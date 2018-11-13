RSpec.describe Keka do

  describe 'Keka::Base' do
    describe '#ok?' do
      it { expect(described_class::Base.new(true, nil)).to be_ok }
      it { expect(described_class::Base.new(false, nil)).not_to be_ok }
    end
  end

  describe 'Keka::Halt' do
    describe 'initialization' do
      it 'is initialized with a Keka::Base' do
        begin
          base = described_class::Base.new(true, nil)
          raise described_class::Halt.new(base)
        rescue described_class::Halt => e
          expect(e.keka).to eq(base)
        end
      end
    end
  end

  describe '.run' do
    it 'returns ok keka if nothing halts' do
      result = described_class.run do
        1 + 1
      end
      expect(result).to be_ok
      expect(result.msg).to be_nil
    end

    it 'returns the correct keka when halted' do
      result = described_class.run do
        described_class.err_if!(true, 'foo')
      end
      expect(result).not_to be_ok
      expect(result.msg).to eq 'foo'
    end

    it 'raises when no block is given' do
      expect{ described_class.run }.to raise_error('Block required!')
    end
  end

  describe '.err_if!' do
    context 'when evaluating keka object,' do
      context 'when keka is ok,' do
        it 'halts' do
          keka = described_class::Base.new(true, nil)
          expect{ described_class.err_if!(keka) }.to raise_error do |error|
            expect(error.keka).not_to be_ok
            expect(error.keka.msg).to be_nil
          end
        end

        describe 'error message' do
          it 'accepts optional error message' do
            keka = described_class::Base.new(true, nil)
            expect{ described_class.err_if!(keka, 'foo') }.to raise_error do |error|
              expect(error.keka).not_to be_ok
              expect(error.keka.msg).to eq 'foo'
            end
          end

          it 'ignores previous keka message' do
            keka = described_class::Base.new(true, 'bar')
            expect{ described_class.err_if!(keka) }.to raise_error do |error|
              expect(error.keka).not_to be_ok
              expect(error.keka.msg).to be_nil
            end
          end
        end
      end

      it 'does not halt when err' do
        keka = described_class::Base.new(false, nil)
        expect{ described_class.err_if!(keka) }.not_to raise_error
      end
    end

    context 'when evaluating other object,' do
      it 'halts if truthy' do
        expect{ described_class.err_if!(true, 'foo') }.to raise_error do |error|
          expect(error.keka).not_to be_ok
          expect(error.keka.msg).to eq 'foo'
        end

        expect{ described_class.err_if!(true) }.to raise_error do |error|
          expect(error.keka).not_to be_ok
          expect(error.keka.msg).to be_nil
        end

        expect{ described_class.err_if!(1) }.to raise_error do |error|
          expect(error.keka).not_to be_ok
          expect(error.keka.msg).to be_nil
        end

        expect{ described_class.err_if!("hello") }.to raise_error do |error|
          expect(error.keka).not_to be_ok
          expect(error.keka.msg).to be_nil
        end
      end

      it 'does not halt if falsy' do
        expect{ described_class.err_if!(false, 'foo') }.not_to raise_error
      end
    end
  end

  describe '.err_unless!' do
    context 'when evaluating keka object,' do
      it 'does not halt when keka is ok' do
        keka = described_class::Base.new(true, nil)
        expect{ described_class.err_unless!(keka) }.not_to raise_error
      end

      context 'when keka is err' do
        it 'halts and reuses the previous keka' do
          keka = described_class::Base.new(false, nil)
          expect{ described_class.err_unless!(keka) }.to raise_error do |error|
            expect(error.keka).to eq keka
            expect(error.keka.msg).to be_nil
          end
        end

        describe 'error message' do
          it 'uses previous keka msg if msg is not provided in argument' do
            keka = described_class::Base.new(false, 'foo')
            expect{ described_class.err_unless!(keka) }.to raise_error do |error|
              expect(error.keka).to eq keka
              expect(error.keka.msg).to eq 'foo'
            end
          end

          it 'changes msg of provided keka when new msg is present' do
            keka = described_class::Base.new(false, 'foo')
            expect{ described_class.err_unless!(keka, 'bar') }.to raise_error do |error|
              expect(error.keka).to eq keka
              expect(keka.msg).to eq 'bar'
            end
          end
        end
      end
    end

    context 'when evaluating other object,' do
      it 'halts if falsy' do
        expect{ described_class.err_unless!(false) }.to raise_error do |error|
          expect(error.keka).not_to be_ok
        end

        expect{ described_class.err_unless!(false, 'foo') }.to raise_error do |error|
          expect(error.keka).not_to be_ok
          expect(error.keka.msg).to eq 'foo'
        end
      end

      it 'does not halt when truthy' do
        expect{ described_class.err_unless!(true) }.not_to raise_error
        expect{ described_class.err_unless!(1) }.not_to raise_error
        expect{ described_class.err_unless!('foo') }.not_to raise_error
      end
    end
  end

  describe '.ok_if!' do
    context 'when evaluating keka object,' do
      context 'when keka is ok,' do
        it 'halts' do
          keka = described_class::Base.new(true, nil)
          expect{ described_class.ok_if!(keka) }.to raise_error do |error|
            expect(error.keka).to be_ok
            expect(error.keka.msg).to be_nil
          end
        end

        describe 'error message' do
          it 'uses previous keka msg if msg is not provided in argument' do
            keka = described_class::Base.new(true, 'foo')
            expect{ described_class.ok_if!(keka) }.to raise_error do |error|
              expect(error.keka).to eq keka
              expect(error.keka.msg).to eq 'foo'
            end
          end

          it 'changes msg of provided keka when new msg is present' do
            keka = described_class::Base.new(true, 'foo')
            expect{ described_class.ok_if!(keka, 'bar') }.to raise_error do |error|
              expect(error.keka).to eq keka
              expect(keka.msg).to eq 'bar'
            end
          end
        end
      end

      it 'does not halt when keka is err' do
        keka = described_class::Base.new(false, nil)
        expect{ described_class.ok_if!(keka) }.not_to raise_error
      end
    end

    context 'when evaluating other object,' do
      it 'halts if truthy' do
        expect{ described_class.ok_if!(true) }.to raise_error do |error|
          expect(error.keka).to be_ok
          expect(error.keka.msg).to be_nil
        end

        expect{ described_class.ok_if!('foo') }.to raise_error do |error|
          expect(error.keka).to be_ok
          expect(error.keka.msg).to be_nil
        end

        expect{ described_class.ok_if!(true, 'foo') }.to raise_error do |error|
          expect(error.keka).to be_ok
          expect(error.keka.msg).to eq 'foo'
        end
      end

      it 'does not halt if falsy' do
        expect{ described_class.ok_if!(false, 'foo') }.not_to raise_error
      end
    end
  end

  describe '.ok' do
    it { expect(described_class.ok).to be_ok }
    it 'accepts message' do
      keka = described_class.ok('foo')
      expect(keka.msg).to eq 'foo'
    end
  end

  describe '.err' do
    it { expect(described_class.err).not_to be_ok }
    it 'accepts message' do
      keka = described_class.err('foo')
      expect(keka.msg).to eq 'foo'
    end
  end

end
