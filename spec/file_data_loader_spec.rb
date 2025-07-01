require 'json'
require 'fileutils'

require_relative '../file_data_loader'

describe FileDataLoader do
  let(:mock_json_data) do
    {
      'rates' => [
        { 'sailing_code' => 'ABCD', 'rate' => '123.45', 'rate_currency' => 'USD' }
      ],
      'exchange_rates' => {
        '2022-01-01' => { 'usd' => 1.12 }
      },
      'sailings' => [
        {
          'origin_port' => 'CNSHA',
          'destination_port' => 'NLRTM',
          'departure_date' => '2022-01-01',
          'arrival_date' => '2022-01-10',
          'sailing_code' => 'ABCD'
        }
      ]
    }
  end

  let(:file_path) { 'spec/fixtures/response.json' }

  before do
    FileUtils.mkdir_p('spec/fixtures')
    File.write(file_path, JSON.pretty_generate(mock_json_data))
  end

  after do
    File.delete(file_path) if File.exist?(file_path)
  end

  describe '.load_data' do
    subject { described_class.load_data(file_path) }

    it 'loads exchange_rates' do
      expect(subject.exchange_rates).to eq(mock_json_data['exchange_rates'])
    end

    it 'loads sailings' do
      expect(subject.sailings).to eq(mock_json_data['sailings'])
    end

    it 'parses rates into a hash keyed by symbol sailing code' do
      expect(subject.rates).to eq({
        ABCD: { rate: '123.45', rate_currency: 'USD' }
      })
    end
  end
end
