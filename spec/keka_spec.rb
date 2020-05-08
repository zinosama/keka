RSpec.describe Keka do
  describe 'Context::Originable' do
    describe '.run' do
      it 'returns ok result when there is no exception' do
        result = Keka.run do
          1 + 1
        end
        expect(result).to be_ok
      end

      it 'returns error result when there is exception' do
        result = Keka.run do
          Keka.err_if! true, 'something went wrong'
        end
        expect(result).not_to be_ok
        expect(result.msg).to eq 'something went wrong'
      end
    end

    describe '.rescue_with' do
      it 'returns ok result when there is no exception' do
        result = Keka.rescue_with(RuntimeError, 'foo').run { 1+ 1 }
        expect(result).to be_ok
        expect(result.msg).to be_nil
      end

      it 'returns error result when expected exception raised' do
        result = Keka.rescue_with(RuntimeError, 'foo').run { raise 'err!' }
        expect(result).not_to be_ok
        expect(result.msg).to eq 'foo'
      end
    end
  end

  describe '.err_if!' do
    context 'when evaluating result object,' do
      context 'when result is ok,' do
        it 'halts' do
          result = described_class::Result.new(true, nil)
          expect{ described_class.err_if!(result) }.to raise_error do |error|
            expect(error.result).not_to be_ok
            expect(error.result.msg).to be_nil
          end
        end

        describe 'error message' do
          it 'accepts optional error message' do
            result = described_class::Result.new(true, nil)
            expect{ described_class.err_if!(result, 'foo') }.to raise_error do |error|
              expect(error.result).not_to be_ok
              expect(error.result.msg).to eq 'foo'
            end
          end

          it 'ignores previous result message' do
            result = described_class::Result.new(true, 'bar')
            expect{ described_class.err_if!(result) }.to raise_error do |error|
              expect(error.result).not_to be_ok
              expect(error.result.msg).to be_nil
            end
          end
        end
      end

      it 'does not halt when err' do
        result = described_class::Result.new(false, nil)
        expect{ described_class.err_if!(result) }.not_to raise_error
      end
    end

    context 'when evaluating other object,' do
      it 'halts if truthy' do
        expect{ described_class.err_if!(true, 'foo') }.to raise_error do |error|
          expect(error.result).not_to be_ok
          expect(error.result.msg).to eq 'foo'
        end

        expect{ described_class.err_if!(true) }.to raise_error do |error|
          expect(error.result).not_to be_ok
          expect(error.result.msg).to be_nil
        end

        expect{ described_class.err_if!(1) }.to raise_error do |error|
          expect(error.result).not_to be_ok
          expect(error.result.msg).to be_nil
        end

        expect{ described_class.err_if!("hello") }.to raise_error do |error|
          expect(error.result).not_to be_ok
          expect(error.result.msg).to be_nil
        end
      end

      it 'does not halt if falsy' do
        expect{ described_class.err_if!(false, 'foo') }.not_to raise_error
      end
    end
  end

  describe '.err_unless!' do
    context 'when evaluating result object,' do
      it 'does not halt when result is ok' do
        result = described_class::Result.new(true, nil)
        expect{ described_class.err_unless!(result) }.not_to raise_error
      end

      context 'when result is err' do
        it 'halts and reuses the previous result' do
          result = described_class::Result.new(false, nil)
          expect{ described_class.err_unless!(result) }.to raise_error do |error|
            expect(error.result).to eq result
            expect(error.result.msg).to be_nil
          end
        end

        describe 'error message' do
          it 'uses previous result msg if msg is not provided in argument' do
            result = described_class::Result.new(false, 'foo')
            expect{ described_class.err_unless!(result) }.to raise_error do |error|
              expect(error.result).to eq result
              expect(error.result.msg).to eq 'foo'
            end
          end

          it 'changes msg of provided result when new msg is present' do
            result = described_class::Result.new(false, 'foo')
            expect{ described_class.err_unless!(result, 'bar') }.to raise_error do |error|
              expect(error.result).to eq result
              expect(result.msg).to eq 'bar'
            end
          end
        end
      end
    end

    context 'when evaluating other object,' do
      it 'halts if falsy' do
        expect{ described_class.err_unless!(false) }.to raise_error do |error|
          expect(error.result).not_to be_ok
        end

        expect{ described_class.err_unless!(false, 'foo') }.to raise_error do |error|
          expect(error.result).not_to be_ok
          expect(error.result.msg).to eq 'foo'
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
    context 'when evaluating result object,' do
      context 'when result is ok,' do
        it 'halts' do
          result = described_class::Result.new(true, nil)
          expect{ described_class.ok_if!(result) }.to raise_error do |error|
            expect(error.result).to be_ok
            expect(error.result.msg).to be_nil
          end
        end

        describe 'error message' do
          it 'uses previous result msg if msg is not provided in argument' do
            result = described_class::Result.new(true, 'foo')
            expect{ described_class.ok_if!(result) }.to raise_error do |error|
              expect(error.result).to eq result
              expect(error.result.msg).to eq 'foo'
            end
          end

          it 'changes msg of provided result when new msg is present' do
            result = described_class::Result.new(true, 'foo')
            expect{ described_class.ok_if!(result, 'bar') }.to raise_error do |error|
              expect(error.result).to eq result
              expect(result.msg).to eq 'bar'
            end
          end
        end
      end

      it 'does not halt when result is err' do
        result = described_class::Result.new(false, nil)
        expect{ described_class.ok_if!(result) }.not_to raise_error
      end
    end

    context 'when evaluating other object,' do
      it 'halts if truthy' do
        expect{ described_class.ok_if!(true) }.to raise_error do |error|
          expect(error.result).to be_ok
          expect(error.result.msg).to be_nil
        end

        expect{ described_class.ok_if!('foo') }.to raise_error do |error|
          expect(error.result).to be_ok
          expect(error.result.msg).to be_nil
        end

        expect{ described_class.ok_if!(true, 'foo') }.to raise_error do |error|
          expect(error.result).to be_ok
          expect(error.result.msg).to eq 'foo'
        end
      end

      it 'does not halt if falsy' do
        expect{ described_class.ok_if!(false, 'foo') }.not_to raise_error
      end
    end
  end

  describe '.err!' do
    it 'halts without msg' do
      expect { described_class.err! }.to raise_error do |error|
        expect(error.result).not_to be_ok
        expect(error.result.msg).to be_nil
      end
    end

    it 'halts with msg' do
      expect { described_class.err!('foo') }.to raise_error do |error|
        expect(error.result).not_to be_ok
        expect(error.result.msg).to eq('foo')
      end
    end
  end

  describe '.ok!' do
    it 'halts without msg' do
      expect { described_class.ok! }.to raise_error do |error|
        expect(error.result).to be_ok
        expect(error.result.msg).to be_nil
      end
    end

    it 'halts with msg' do
      expect { described_class.ok!('foo') }.to raise_error do |error|
        expect(error.result).to be_ok
        expect(error.result.msg).to eq('foo')
      end
    end
  end

  describe '.ok_result' do
    it { expect(described_class.ok_result).to be_ok }
    it 'accepts message' do
      result = described_class.ok_result('foo')
      expect(result.msg).to eq 'foo'
    end
  end

  describe '.err_result' do
    it { expect(described_class.err_result).not_to be_ok }
    it 'accepts message' do
      result = described_class.err_result('foo')
      expect(result.msg).to eq 'foo'
    end
  end
end
