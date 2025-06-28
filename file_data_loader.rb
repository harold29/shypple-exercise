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
    @rates = load_rates
    @exchange_rates = parse_json_file['exchange_rates']
    @sailings = parse_json_file['sailings']
  end

  # def load_data

  # end

  def load_rates
    rates_values = parse_json_file['rates']
    rates = {}

    rates_values.each do |rate|
      rates[rate['sailing_code'].to_sym] = {
        rate: rate['rate'],
        rate_currency: rate['rate_currency']
      }
    end

    rates
  end

  def parse_json_file
    @parse_json_file ||= JSON.parse(File.read(@file_path))
  end
end
