require_relative './node'

RSpec.describe TrafficDirectorNode do
  let(:subject) { described_class.new(director_values, child_node_paths) }
  let(:director_values) { [1] }
  let(:child_node_paths) { ['file/path'] }
  let(:equals) { :EQUAL }

  describe '.initialize' do
    it 'assigns traffic directors' do
      expect(subject.instance_variable_get(:@director_values))
        .to be(director_values)
    end

    it 'assigns child nodes' do
      expect(subject.instance_variable_get(:@child_node_paths))
        .to be(child_node_paths)
    end
  end

  describe '#tuple_and_node_for_target' do
    let(:director_values) { [1, 3, 5] }
    let(:child_node_paths) { ['file/path/1', 'file/path/3', 'file/path/5'] }

    context 'when the condition is EQUALS' do
      it 'opens the correct file when the target is 0' do
        expect(File).to receive(:open).with('file/path/1')
        subject.tuple_and_node_for_target(0, equals)
      end

      it 'opens the correct file when the target is 3' do
        expect(File).to receive(:open).with('file/path/3')
        subject.tuple_and_node_for_target(3, equals)
      end

      it 'does not open any file when there is no match' do
        expect(File).not_to receive(:open)
        subject.tuple_and_node_for_target(6, equals)
      end

      it 'returns nil when there is no match' do
        expect(subject.tuple_and_node_for_target(6, equals)).to be(nil)
      end
    end

    context 'when the condition is GREATER' do
      let(:greater) { :GREATER }

      it 'opens the correct file when the target is 2' do
        expect(File).to receive(:open).with('file/path/3')
        subject.tuple_and_node_for_target(2, greater)
      end

      it 'opens the correct file when the target is 3' do
        expect(File).to receive(:open).with('file/path/5')
        subject.tuple_and_node_for_target(3, greater)
      end

      it 'does not open any file when there is no match' do
        expect(File).not_to receive(:open)
        subject.tuple_and_node_for_target(5, greater)
        subject.tuple_and_node_for_target(6, greater)
      end

      it 'returns nil when there is no match' do
        expect(subject.tuple_and_node_for_target(6, greater))
          .to be(nil)
      end
    end

    context 'when the condition is LESS' do
      let(:less) { :LESS }

      it 'opens the correct file when the target is 2' do
        expect(File).to receive(:open).with('file/path/3')
        subject.tuple_and_node_for_target(2, less)
      end

      it 'opens the correct file when the target is 3' do
        expect(File).to receive(:open).with('file/path/3')
        subject.tuple_and_node_for_target(3, less)
      end

      it 'opens the correct file when the target is 4' do
        expect(File).to receive(:open).with('file/path/5')
        subject.tuple_and_node_for_target(4, less)
      end

      it 'opens the correct file when the target is 5' do
        expect(File).to receive(:open).with('file/path/5')
        subject.tuple_and_node_for_target(5, less)
      end

      it 'opens the correct file when the target is 6' do
        expect(File).to receive(:open).with('file/path/5')
        subject.tuple_and_node_for_target(6, less)
      end
    end
  end

  describe '#==' do
    it 'returns true when all equality conditions are met' do
      other_node = described_class.new(director_values, child_node_paths)
      expect(subject == other_node).to be(true)
    end

    it 'returns false when the other node is not a TrafficDirectorNode' do
      other_node = LeafNode.new(['stub'], ['fake'])
      expect(subject == other_node).to be(false)
    end

    it 'returns false when the director values are not equal' do
      other_node = described_class.new(director_values + [1], child_node_paths)
      expect(subject == other_node).to be(false)
    end

    it 'returns false when the child node paths are not equal' do
      other_node = described_class.new(director_values, child_node_paths + ['1'])
      expect(subject == other_node).to be(false)
    end
  end
end

RSpec.describe LeafNode do
  let(:subject) { described_class.new(tuples, next_node_file_path) }
  let(:tuples) { %w[1,a, 2,b, 2,c, 2,d, 3,e,] }
  let(:next_node_file_path) { 'next_node_file_path' }

  describe '.initialize' do
    it 'assigns tuples' do
      expect(subject.instance_variable_get(:@tuples)).to be(tuples)
    end

    it 'assigns file path' do
      expect(subject.instance_variable_get(:@next_node_file_path))
        .to be(next_node_file_path)
    end
  end

  describe '#tuple_and_node_for_target' do
    context 'when the condition is EQUALS' do
      let(:equals) { :EQUAL }

      it 'returns the correct tuple when the target is 1' do
        expect(subject.tuple_and_node_for_target(1, equals))
          .to include(node: subject, tuple: '1,a,')
      end

      it 'returns the correct tuple when the target is 2' do
        expect(subject.tuple_and_node_for_target(2, equals))
          .to include(node: subject, tuple: '2,b,')
      end

      it 'returns nil if the target does not exist' do
        expect(subject.tuple_and_node_for_target(5_000, equals))
          .to be(nil)
      end

      it 'returns the correct tuples when the same node is called multiple times' do
        expect(subject.tuple_and_node_for_target(2, equals))
          .to include(node: subject, tuple: '2,b,')
        expect(subject.tuple_and_node_for_target(2, equals))
          .to include(node: subject, tuple: '2,c,')
        expect(subject.tuple_and_node_for_target(2, equals))
          .to include(node: subject, tuple: '2,d,')
        expect(subject.tuple_and_node_for_target(2, equals))
          .to be(nil)
      end
    end

    context 'when the condition is GREATER' do
      let(:greater) { :GREATER }

      it 'returns the correct tuple when the target is 1' do
        expect(subject.tuple_and_node_for_target(1, greater))
          .to include(node: subject, tuple: '2,b,')
      end

      it 'returns the correct tuple when the target is 2' do
        expect(subject.tuple_and_node_for_target(2, greater))
          .to include(node: subject, tuple: '3,e,')
      end

      it 'returns nil when no value is greater than the target' do
        expect(subject.tuple_and_node_for_target(4, greater))
          .to be(nil)
      end

      it 'returns the correct tuples when the same node is called multiple times' do
        expect(subject.tuple_and_node_for_target(1, greater))
          .to include(node: subject, tuple: '2,b,')
        expect(subject.tuple_and_node_for_target(1, greater))
          .to include(node: subject, tuple: '2,c,')
        expect(subject.tuple_and_node_for_target(1, greater))
          .to include(node: subject, tuple: '2,d,')
        expect(subject.tuple_and_node_for_target(1, greater))
          .to include(node: subject, tuple: '3,e,')
        expect(subject.tuple_and_node_for_target(1, greater))
          .to be(nil)
      end
    end

    context 'when the condition is LESS' do
      let(:less) { :LESS }

      it 'returns the correct tuple when the target is 3' do
        expect(subject.tuple_and_node_for_target(3, less))
          .to include(node: subject, tuple: '1,a,')
      end

      it 'returns the correct tuple when the target is 2' do
        expect(subject.tuple_and_node_for_target(2, less))
          .to include(node: subject, tuple: '1,a,')
      end

      it 'returns nil when no value is less than the target' do
        expect(subject.tuple_and_node_for_target(1, less))
          .to be(nil)
      end

      it 'returns the correct tuples when the same node is called multiple times' do
        expect(subject.tuple_and_node_for_target(3, less))
          .to include(node: subject, tuple: '1,a,')
        expect(subject.tuple_and_node_for_target(3, less))
          .to include(node: subject, tuple: '2,b,')
        expect(subject.tuple_and_node_for_target(3, less))
          .to include(node: subject, tuple: '2,c,')
        expect(subject.tuple_and_node_for_target(3, less))
          .to include(node: subject, tuple: '2,d,')
        expect(subject.tuple_and_node_for_target(3, less))
          .to be(nil)
      end
    end
  end

  describe '#==' do
    it 'returns true when all equality conditions are met' do
      other_node = described_class.new(tuples, next_node_file_path)
      expect(subject == other_node).to be(true)
    end

    it 'returns false when the tuples are not equal' do
      other_node = described_class.new(tuples + ['abc,'], next_node_file_path)
      expect(subject == other_node).to be(false)
    end

    it 'returns false when the next node file paths are not equal' do
      other_node = described_class.new(tuples, next_node_file_path + 'a')
      expect(subject == other_node).to be(false)
    end

    it 'returns false when the node is not a leaf node' do
      other_node = TrafficDirectorNode.new('fake', 'stub')
      expect(subject == other_node).to be(false)
    end
  end
end
