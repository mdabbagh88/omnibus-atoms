require_relative '../../lib/atoms/build_iteration.rb'

describe Atoms::BuildIteration do
  describe :build_iteration do
    subject { Atoms::BuildIteration.new(git_describe) }

    context 'with an invalid git_describe' do
      let(:git_describe) { '1.2.3-foo.3' }

      it 'returns 0' do
        expect(subject.build_iteration).to eq('0')
      end
    end

    context 'with a git_describe from master' do
      let(:git_describe) { '1.2.3+rc1.ce.2-6-ge5626d5' }

      it 'returns rc1.ce.2' do
        expect(subject.build_iteration).to eq('rc1.ce.2')
      end
    end

    context 'with a proper git_describe' do
      let(:git_describe) { '1.2.3+foo.4' }

      it 'returns foo.4' do
        expect(subject.build_iteration).to eq('foo.4')
      end
    end

    context 'with a git_describe with new line char' do
      let(:git_describe) { "1.2.3+foo.4\n" }

      it 'returns foo.4' do
        expect(subject.build_iteration).to eq('foo.4')
      end
    end

    context 'with multiple plus signs' do
      let(:git_describe) { '1.2.3+foo.4+bar' }

      it 'returns everything after the first plus' do
        expect(subject.build_iteration).to eq('foo.4+bar')
      end
    end


    context 'with an invalid git tag' do
      let(:git_describe) { '1.2.3+' }

      it 'returns an empty string' do
        expect(subject.build_iteration).to eq('0')
      end
    end
  end
end
