# frozen_string_literal: true

require_relative './index_scan'
require_relative './node'

RSpec.describe IndexScan do
  let(:subject) { described_class.new(file_path, target, condition) }
  let(:file_path) { 'file_path' }
  let(:target) { 1 }
  let(:condition) { :EQUAL }

  describe '.initialize' do
    it 'assigns a file path' do
      expect(subject.instance_variable_get(:@file_path)).to be(file_path)
    end

    it 'assigns a target' do
      expect(subject.instance_variable_get(:@target)).to be(target)
    end

    it 'assigns a condition' do
      expect(subject.instance_variable_get(:@condition)).to be(condition)
    end
  end

  describe '#next' do
    let(:spec_directory) { '/Users/samturner/Desktop/DBMS/spec/index_scan_files' }

    context 'with one leaf node in the chain' do
      let(:file_path) { "#{spec_directory}/single_leaf_node/leaf.txt" }

      it 'returns the correct tuples when the target exists' do
        index_scan = described_class.new(file_path, 1, :EQUAL)
        expect(index_scan.next).to eq('1,a,')
        expect(index_scan.next).to eq(described_class::END_OF_FILE)
      end

      it 'immediately returns EOF when the target does not exist' do
        index_scan = described_class.new(file_path, 5, :EQUAL)
        expect(index_scan.next).to eq(described_class::END_OF_FILE)
      end
    end

    context 'with multiple leaf nodes in the chain' do
      let(:file_path) { "#{spec_directory}/multiple_leaf_nodes/leaf_1.txt" }

      it 'returns the correct tuples when the target exists on the first node' do
        index_scan = described_class.new(file_path, 3, :EQUAL)
        expect(index_scan.next).to eq('3,c,')
        expect(index_scan.next).to eq('3,d,')
        expect(index_scan.next).to eq(described_class::END_OF_FILE)
      end

      it 'returns EOF when the target does not exist' do
        index_scan = described_class.new(file_path, 10, :EQUAL)
        expect(index_scan.next).to eq(described_class::END_OF_FILE)
      end
    end

    context 'with one traffic director and multiple leaf nodes' do
      let(:file_path) { "#{spec_directory}/traffic_director/traffic_director.txt" }

      it 'returns the correct tuples when the target exists' do
        index_scan = described_class.new(file_path, 3, :EQUAL)
        expect(index_scan.next).to eq('3,c,')
        expect(index_scan.next).to eq(described_class::END_OF_FILE)
      end

      it 'returns the correct tuples when the target exists twice' do
        index_scan = described_class.new(file_path, 7, :EQUAL)
        expect(index_scan.next).to eq('7,g,')
        expect(index_scan.next).to eq('7,h,')
        expect(index_scan.next).to eq(described_class::END_OF_FILE)
      end

      it 'returns EOF when the target does not exist' do
        index_scan = described_class.new(file_path, 10, :EQUAL)
        expect(index_scan.next).to eq(described_class::END_OF_FILE)
      end
    end

    context 'with multiple levels of traffic directors and multiple leaf nodes' do
      let(:file_path) { "#{spec_directory}/multiple_traffic_directors/traffic_director_1.txt" }

      it 'returns the correct tuples when the target exists on the first leaf node' do
        index_scan = described_class.new(file_path, 3, :EQUAL)
        expect(index_scan.next).to eq('3,d,')
        expect(index_scan.next).to eq(described_class::END_OF_FILE)
      end

      it 'returns the correct tuples when the target exists on the second leaf node' do
        index_scan = described_class.new(file_path, 6, :EQUAL)
        expect(index_scan.next).to eq('6,g,')
        expect(index_scan.next).to eq('6,h,')
        expect(index_scan.next).to eq(described_class::END_OF_FILE)
      end

      it 'returns the correct tuples when the target exists on the last leaf node' do
        index_scan = described_class.new(file_path, 19, :EQUAL)
        expect(index_scan.next).to eq('19,t,')
        expect(index_scan.next).to eq('19,u,')
        expect(index_scan.next).to eq(described_class::END_OF_FILE)
      end
    end
  end
end
