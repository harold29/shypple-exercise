require_relative '../node'
require_relative '../connection'

describe Node do
  context '#initialize' do
    let(:location) { 'Paris' }

    it 'is initialized with location information' do
      node = Node.new(location)

      expect(node.location).to eq(location)
      expect(node.connections).to eq([])
      expect(node.connection_hash).to eq({})
    end

    context 'with missing data' do
      it 'raises an error when location is missing' do
        expect {
          Node.new(nil)
        }.to raise_error(ArgumentError, /location is required/)
      end

      it 'raises an error if location is an empty string' do
        expect {
          Node.new("")
        }.to raise_error(ArgumentError, /location is required/)
      end

      it 'raises an error if location is just whitespace' do
        expect {
          Node.new("   ")
        }.to raise_error(ArgumentError, /location is required/)
      end
    end
  end

  context '#connect_to' do
    let(:node1) { Node.new('PAR') }
    let(:node2) { Node.new('AMS') }
    let(:departure_date) { '2024-02-19' }
    let(:arrival_date) { '2024-02-26' }
    let(:rate) { '500' }
    let(:rate_currency) { 'USD' }
    let(:code) { 'ABCD' }

    before do
      node1.connect_to(node2,
                      departure_date: departure_date,
                      arrival_date: arrival_date,
                      rate: rate,
                      rate_currency: rate_currency,
                      code: code)
    end

    it 'adds the connection to the connections array' do
      expect(node1.connections.length).to eq(1)
      expect(node1.connections.first).to be_a(Connection)
      expect(node1.connections.first.target_node).to eq(node2)
    end

    it 'stores the connection in the connection_hash' do
      expect(node1.connection_hash['AMS']).to be_an(Array)
      expect(node1.connection_hash['AMS'].first).to be_a(Connection)
    end

    it 'adds multiple connections to the same target_node key' do
      node1.connect_to(node2,
                      departure_date: '2024-03-01',
                      arrival_date: '2024-03-02',
                      rate: '550',
                      rate_currency: 'USD',
                      code: 'XYZ')

      expect(node1.connection_hash['AMS'].size).to eq(2)
    end

    it 'does not affect connection_hash for unrelated nodes' do
      node3 = Node.new('LON')
      expect(node1.connection_hash['LON']).to be_nil
    end
  end
end
