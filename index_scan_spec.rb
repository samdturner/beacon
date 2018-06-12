# frozen_string_literal: true

require_relative './index_scan'
require_relative './node'

RSpec.describe IndexScan do
  describe '.initialize' do
    let(:subject) { described_class.new(root, target, condition) }
    let(:root) { double }
    let(:target) { 1 }
    let(:condition) { :EQUAL }

    it 'assigns a root' do
      expect(subject.instance_variable_get(:@current_node)).to be(root)
    end

    it 'assigns a target' do
      expect(subject.instance_variable_get(:@target)).to be(target)
    end

    it 'assigns a condition' do
      expect(subject.instance_variable_get(:@condition)).to be(condition)
    end
  end

  describe '#next' do
    context 'when the current node returns nil' do
      let(:subject) { described_class.new(root, target, condition) }
      let(:root) { TrafficDirectorNode.new(100, []) }
      let(:target) { 1 }
      let(:condition) { :EQUAL }

      it 'returns :EOF' do
        expect(subject.next).to be(described_class::END_OF_FILE)
      end
    end

    context 'when the current node returns a tuple and the next node' do
      let(:subject) { described_class.new(root, target, condition) }
      let(:root) { TrafficDirectorNode.new(0, [leaf_node]) }
      let(:tuple) { '1,a,' }
      let(:leaf_node) { LeafNode.new(tuple, nil) }
      let(:target) { 1 }
      let(:condition) { :EQUAL }

      it 'returns the second tuple correctly' do
        expect(subject.next).to eq(tuple)
      end
    end
  end
end
