require 'json'
require 'date'

require_relative '../route_finder'
require_relative '../node'
require_relative '../connection'

describe RouteFinder do
  let(:origin_node) { Node.new(:CNSHA) }
  let(:intermediate_node) { Node.new(:ESBCN) }
  let(:destination_node) { Node.new(:NLRTM) }

  let(:exchange_rates) do
    {
      '2022-01-01' => { 'usd' => 1.12, 'jpy' => 130.0 },
      '2022-01-10' => { 'usd' => 1.10 },
      '2022-01-15' => { 'usd' => 1.08 }
    }
  end

  let(:direct_connection) do
    Connection.new(origin_node, destination_node,
                   departure_date: Date.parse('2022-01-01'),
                   arrival_date: Date.parse('2022-01-10'),
                   rate: '250.0',
                   rate_currency: 'USD',
                   code: 'D001')
  end

  let(:indirect_connection_1) do
    Connection.new(origin_node, intermediate_node,
                   departure_date: Date.parse('2022-01-01'),
                   arrival_date: Date.parse('2022-01-05'),
                   rate: '100.0',
                   rate_currency: 'EUR',
                   code: 'I001')
  end

  let(:indirect_connection_2) do
    Connection.new(intermediate_node, destination_node,
                   departure_date: Date.parse('2022-01-10'),
                   arrival_date: Date.parse('2022-01-15'),
                   rate: '110.0',
                   rate_currency: 'USD',
                   code: 'I002')
  end

  let(:graph) do
    {
      CNSHA: origin_node,
      ESBCN: intermediate_node,
      NLRTM: destination_node
    }.tap do |nodes|
      origin_node.connection_hash[:NLRTM] = [direct_connection]
      origin_node.connection_hash[:ESBCN] = [indirect_connection_1]
      intermediate_node.connection_hash[:NLRTM] = [indirect_connection_2]
    end
  end

  subject { described_class.new(graph: graph, exchange_rates: exchange_rates) }

  describe '#find' do
    context 'cheapest-direct' do
      it 'returns the cheapest direct route' do
        result = subject.find(:CNSHA, :NLRTM, 'cheapest-direct')
        expect(result).to be_an(Array)
        expect(result.first[:sailing_code]).to eq('D001')
        expect(result.first[:rate_currency]).to eq('USD')
      end
    end

    context 'cheapest (indirect allowed)' do
      it 'returns the cheapest indirect route in multiple legs' do
        result = subject.find(:CNSHA, :NLRTM, 'cheapest')
        expect(result).to be_an(Array)
        expect(result.size).to eq(2)
        expect(result.first[:origin_port]).to eq('CNSHA')
        expect(result.last[:destination_port]).to eq('NLRTM')
      end
    end

    context 'fastest' do
      it 'returns the route with the shortest total time' do
        result = subject.find(:CNSHA, :NLRTM, 'fastest')
        expect(result).to be_an(Array)
        expect(result.first[:origin_port]).to eq('CNSHA')
        expect(result.last[:destination_port]).to eq('NLRTM')
      end
    end

    context 'invalid criteria' do
      it 'raises an ArgumentError' do
        expect {
          subject.find(:CNSHA, :NLRTM, 'slowest')
        }.to raise_error(ArgumentError)
      end
    end

    context 'when a connection is missing from filled_connections' do
      it 'raises an error in build_response' do
        result = {
          path: [:CNSHA, :NLRTM],
          connections: {} # Simulate missing connections
        }

        # Temporarily override private method
        expect {
          subject.send(:build_response, result)
        }.to raise_error(RuntimeError, /Missing connection from CNSHA to NLRTM/)
      end
    end
  end
end
