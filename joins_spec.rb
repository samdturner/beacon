# frozen_string_literal: true

require_relative './joins'

class Generator
  def initialize(elements)
    @elements = elements
  end

  def next
    return 'EOF' if @elements.empty?
    @elements.shift
  end
end

RSpec.describe NestedLoopJoin do
  let(:subject) { described_class.new(left_child, right_child, &condition) }
  let(:left_child) { 'left_child' }
  let(:right_child) { 'right_child' }
  let(:condition) { ->(left_tuple, right_tuple) { left_tuple == right_tuple } }

  describe '#initialize' do
    it 'assigns a left child' do
      expect(subject.instance_variable_get(:@left_child)).to eq('left_child')
    end

    it 'assigns a right child' do
      expect(subject.instance_variable_get(:@right_child)).to eq('right_child')
    end

    it 'assigns a condition block' do
      expect(subject.instance_variable_get(:@condition)).to eq(condition)
    end
  end

  describe '#next' do
    context 'when the condition returns on the first pair of tuples' do
      let(:left_child) { Generator.new(['1,']) }
      let(:right_child) { Generator.new(['1,']) }

      it 'returns the first tuples joined together' do
        expect(subject.next).to eq('1,1,')
      end
    end

    context 'when the condition is not true until the second pair of tuples' do
      let(:left_child) { Generator.new(['1,', '2,']) }
      let(:right_child) { Generator.new(['2,', '2,']) }

      it 'returns the second tuples joined together' do
        expect(subject.next).to eq('2,2,')
      end
    end

    context 'when the condition is not true until the third pair of tuples' do
      let(:left_child) { Generator.new(['1,', '2,', '3,']) }
      let(:right_child) { Generator.new(['a,', 'b,', '3,']) }

      it 'returns the third tuples joined together' do
        expect(subject.next).to eq('3,3,')
      end
    end

    context 'when the children return EOF' do
      let(:left_child) { Generator.new(['EOF']) }
      let(:right_child) { Generator.new(['EOF']) }

      it 'returns EOF' do
        expect(subject.next).to eq('EOF')
      end
    end

    context 'when there are multiple matching records' do
      let(:left_child) { Generator.new(['1,a,', '1,b,', '1,c,', NestedLoopJoin::END_OF_FILE]) }
      let(:right_child) { Generator.new(['1,d,', '2,b,', '1,e,', NestedLoopJoin::END_OF_FILE]) }
      let(:condition) { ->(left_tuple, right_tuple) { left_tuple[0] == right_tuple[0] } }

      it 'returns the next pair of matching tuples on each call' do
        expect(subject.next).to eq('1,a,1,d,')
        expect(subject.next).to eq('1,a,1,e,')
        expect(subject.next).to eq('1,b,1,d,')
        expect(subject.next).to eq('1,b,1,e,')
        expect(subject.next).to eq('1,c,1,d,')
        expect(subject.next).to eq('1,c,1,e,')
        expect(subject.next).to eq(NestedLoopJoin::END_OF_FILE)
      end
    end

    context 'when there are a different number of records in each child' do
      let(:left_child) { Generator.new(['1,a,', NestedLoopJoin::END_OF_FILE]) }
      let(:right_child) { Generator.new(['1,d,', '2,b,', '1,e,', NestedLoopJoin::END_OF_FILE]) }
      let(:condition) { ->(left_tuple, right_tuple) { left_tuple[0] == right_tuple[0] } }

      it 'returns the next pair of matching tuples on each call' do
        expect(subject.next).to eq('1,a,1,d,')
        expect(subject.next).to eq('1,a,1,e,')
        expect(subject.next).to eq(NestedLoopJoin::END_OF_FILE)
      end
    end
  end
end