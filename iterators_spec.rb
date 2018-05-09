require_relative './iterators'


RSpec.describe FileScan do
  let(:subject) { described_class.new(filename) }
  let(:filename) { 'filename' }

  before do
    allow(File).to receive(:open).with(filename).and_return([1,2,3])
  end

  describe '#initialize' do
    it 'opens the file' do
      described_class.new(filename)
      expect(File).to have_received(:open).with(filename)
    end
  end

  describe '#next' do
    it 'returns the first element in the array' do
      expect(subject.next).to eq(1)
    end

    it 'returns all three elements in order when called sequentially' do
      expect(subject.next).to eq(1)
      expect(subject.next).to eq(2)
      expect(subject.next).to eq(3)
    end

    it ''
  end
end

RSpec.describe Distinct do
  describe '#initialize' do
    it 'assigns a previous value' do
      expect(subject.previous_value).to be(nil)
    end
  end
end