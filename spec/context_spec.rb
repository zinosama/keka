module Keka
  RSpec.describe Context do
    let(:context) { described_class.new }

    describe '#rescue_with' do
      it 'updates rescue setting' do
        expect { context.rescue_with(StandardError, 'a standard error') }
          .to change { context.instance_variable_get(:@opts)[:rescue_exceptions] }
          .from([])
          .to([{ klass: StandardError, msg: 'a standard error' }])
      end

      it 'is chainable' do
        output = context.rescue_with(RuntimeError, 'runtime error occurred')
          .rescue_with(TypeError)
        expect(output.instance_variable_get(:@opts)[:rescue_exceptions]).to contain_exactly(
          { klass: RuntimeError, msg: 'runtime error occurred' },
          { klass: TypeError, msg: nil }
        )
      end
    end

    describe '#run' do
      it 'returns ok result when no exception is raised' do
        result = context.run do
          1 + 1
        end
        expect(result).to be_ok
        expect(result.msg).to be_nil
      end

      it 'returns error result when Halt exception is raised' do
        result = context.run do
          Keka.err_if!(true, 'foo')
        end
        expect(result).not_to be_ok
        expect(result.msg).to eq 'foo'
      end

      it 'raises exception when unexpected exception is raised' do
        expect { context.run { raise 'Foo' } }.to raise_exception('Foo')
      end

      it 'returns error result when an expected exception is raised' do
        result = context.rescue_with(RuntimeError, 'an error occurred')
          .run { raise 'Foo' }
        expect(result).not_to be_ok
        expect(result.msg).to eq 'an error occurred'
      end

      it 'does not rescue exceptions that are not descendants of StandardError' do
        expect { context.rescue_with(NoMemoryError).run { raise NoMemoryError.new } }
          .to raise_exception(NoMemoryError)
      end

      it 'raises when no block is given' do
        expect{ context.run }.to raise_error('Block required!')
      end
    end
  end
end
