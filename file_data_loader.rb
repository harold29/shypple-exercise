# frozen_string_literal: true

require 'json'

class FileDataLoader
  attr_accessor :exchange_rates,
                :rates,
                :sailings

  def self.load_data(file_path)
    new(file_path)
  end

  def initialize(file_path)
    @file_path = file_path
    @rates = parse_rates(load_rates)
    @exchange_rates = parse_json_file['exchange_rates']
    @sailings = parse_json_file['sailings']
  end

  private

  def load_rates
    parse_json_file.fetch('rates', [])
  end

  def parse_rates(raw_rates)
    raw_rates.each_with_object({}) do |rate, hash|
      code = rate['sailing_code']
      next unless code

      hash[code.to_sym] = build_rate_entry(rate)
    end
  end

  def build_rate_entry(rate)
    {
      rate: rate['rate'],
      rate_currency: rate['rate_currency']
    }
  end

  def parse_json_file
    @parse_json_file ||= JSON.parse(File.read(@file_path))
  end
end
