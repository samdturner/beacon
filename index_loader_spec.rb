require_relative './index_loader'
require_relative './node'

RSpec.describe IndexLoader do
  let(:file_path) { '/Users/samturner/Desktop/DBMS/spec/index_loader_files' }

  describe '.call' do
    context 'when the file represents a traffic director node' do
      it 'returns a node with no children' do
        expect(described_class.call("#{file_path}/file1.txt"))
          .to eq(TrafficDirectorNode.new([], []))
      end

      it 'returns a node with one child' do
        expect(described_class.call("#{file_path}/file2.txt"))
          .to eq(TrafficDirectorNode.new([1], ['file_path1']))
      end

      it 'returns a node with multiple children' do
        expect(described_class.call("#{file_path}/file3.txt"))
          .to eq(TrafficDirectorNode.new([3, 4], %w[file_path3 file_path4]))
      end
    end

    context 'when the file represents a leaf node' do
      it 'returns a node with no children' do
        expect(described_class.call("#{file_path}/file4.txt"))
          .to eq(LeafNode.new([], nil))
      end

      it 'returns a node with one child' do
        expect(described_class.call("#{file_path}/file5.txt"))
          .to eq(LeafNode.new(['5,'], 'file_path5'))
      end

      it 'returns a node with multiple children' do
        expect(described_class.call("#{file_path}/file6.txt"))
          .to eq(LeafNode.new(['1,a,', '2,b,', '3,c,'], 'file_path6'))
      end
    end
  end
end
