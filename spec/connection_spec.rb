require_relative '../node'
require_relative '../connection'

require 'date'

describe Connection do
  let(:origin_node) { double('Node', location: 'NYC') }
  let(:target_node) { double('Node', location: 'AMS') }

  let(:departure_date) { Date.new(2025, 7, 1) }
  let(:arrival_date)   { Date.new(2025, 7, 2) }
  let(:rate)           { 450.0 }
  let(:rate_currency)  { 'USD' }
  let(:code)           { 'ABC123' }

  subject do
    described_class.new(
      origin_node,
      target_node,
      departure_date: departure_date,
      arrival_date: arrival_date,
      rate: rate,
      rate_currency: rate_currency,
      code: code
    )
  end

  describe '#initialize' do
    it 'sets the origin_node' do
      expect(subject.origin_node).to eq(origin_node)
    end

    it 'sets the target_node' do
      expect(subject.target_node).to eq(target_node)
    end

    it 'sets the departure_date' do
      expect(subject.departure_date).to eq(departure_date)
    end

    it 'sets the arrival_date' do
      expect(subject.arrival_date).to eq(arrival_date)
    end

    it 'sets the rate' do
      expect(subject.rate).to eq(rate)
    end

    it 'sets the rate_currency' do
      expect(subject.rate_currency).to eq(rate_currency)
    end

    it 'sets the code' do
      expect(subject.code).to eq(code)
    end
  end

  describe 'validations' do
    it 'raises error if origin_node and target_node are the same' do
      expect {
        described_class.new(
          origin_node,
          origin_node,
          departure_date: departure_date,
          arrival_date: arrival_date,
          rate: rate,
          rate_currency: rate_currency,
          code: code
        )
      }.to raise_error(ArgumentError, /must be different/)
    end

    it 'raises error if departure_date is after or same as arrival_date' do
      expect {
        described_class.new(
          origin_node,
          target_node,
          departure_date: Date.new(2025, 7, 2),
          arrival_date: Date.new(2025, 7, 2),
          rate: rate,
          rate_currency: rate_currency,
          code: code
        )
      }.to raise_error(ArgumentError, /departure_date must be before/)
    end

    it 'raises error if rate is zero or negative' do
      expect {
        described_class.new(
          origin_node,
          target_node,
          departure_date: departure_date,
          arrival_date: arrival_date,
          rate: 0,
          rate_currency: rate_currency,
          code: code
        )
      }.to raise_error(ArgumentError, /rate must be positive/)
    end
  end
end
