require_relative '../graph_builder'

describe GraphBuilder do
  let(:sailings) do
    [
      {
        'origin_port' => 'NYC',
        'destination_port' => 'LON',
        'departure_date' => '2025-07-01',
        'arrival_date' => '2025-07-10',
        'sailing_code' => 'S001'
      },
      {
        'origin_port' => 'LON',
        'destination_port' => 'AMS',
        'departure_date' => '2025-07-12',
        'arrival_date' => '2025-07-15',
        'sailing_code' => 'S002'
      }
    ]
  end

  let(:rates) do
    {
      S001: { rate: 1000.0, rate_currency: 'USD' },
      S002: { rate: 800.0, rate_currency: 'EUR' }
    }
  end

  describe '.build_graph' do
    it 'returns a hash of Node objects keyed by port symbol' do
      graph = GraphBuilder.build_graph(sailings, rates)

      expect(graph.keys).to contain_exactly(:NYC, :LON, :AMS)
      expect(graph[:NYC]).to be_a(Node)
      expect(graph[:LON]).to be_a(Node)
      expect(graph[:AMS]).to be_a(Node)
    end

    it 'creates connections between the appropriate nodes' do
      graph = GraphBuilder.build_graph(sailings, rates)

      nyc_node = graph[:NYC]
      lon_node = graph[:LON]
      ams_node = graph[:AMS]

      expect(nyc_node.connections.size).to eq(1)
      expect(nyc_node.connections.first.target_node).to eq(lon_node)
      expect(nyc_node.connections.first.code).to eq(:S001)

      expect(lon_node.connections.size).to eq(1)
      expect(lon_node.connections.first.target_node).to eq(ams_node)
      expect(lon_node.connections.first.code).to eq(:S002)
    end

    it 'assigns the correct rate and currency from rates data' do
      graph = GraphBuilder.build_graph(sailings, rates)

      connection1 = graph[:NYC].connections.first
      expect(connection1.rate).to eq(1000.0)
      expect(connection1.rate_currency).to eq(:USD)

      connection2 = graph[:LON].connections.first
      expect(connection2.rate).to eq(800.0)
      expect(connection2.rate_currency).to eq(:EUR)
    end
  end
end
