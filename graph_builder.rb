# frozen_string_literal: true

require 'date'
# require 'json'

require_relative 'node'
require_relative 'connection'

# Builds a graph from file data
class GraphBuilder
  def self.build_graph(sailings, rates)
    new(sailings, rates).build_graph
  end

  def initialize(sailings, rates)
    @sailings = sailings
    @rates = rates
  end

  def build_graph
    graph = nil

    # sailings = parse_json_file['sailings']
    # rates = load_rates
    # rates = @file_data.rates

    nodes = {}

    @sailings.each do |sailing|
      origin_port = sailing['origin_port'].to_sym
      destination_port = sailing['destination_port'].to_sym

      unless nodes[origin_port]
        origin_node = Node.new(origin_port)
        nodes[origin_port] = origin_node

        graph = origin_node unless graph
      end

      unless nodes[destination_port]
        target_node = Node.new(destination_port)
        nodes[destination_port] = target_node
      end

      nodes[origin_port].connect_to(nodes[destination_port],
                                    departing_date: Date.parse(sailing['departure_date']),
                                    arriving_date: Date.parse(sailing['arrival_date']),
                                    rate: @rates[sailing['sailing_code'].to_sym][:rate],
                                    rate_currency: @rates[sailing['sailing_code'].to_sym][:rate_currency].to_sym,
                                    code: sailing['sailing_code'].to_sym)
    end

    # graph
    nodes
  end

  # def load_rates
  #   rates_values = parse_json_file['rates']
  #   rates = {}

  #   rates_values.each do |rate|
  #     rates[rate['sailing_code'].to_sym] = {
  #       rate: rate['rate'],
  #       rate_currency: rate['rate_currency']
  #     }
  #   end

  #   rates
  # end

  # def parse_json_file
  #   @parse_json_file ||= JSON.parse(File.read(@file_path))
  # end
  # def file_data
  #   @file_data = FileDataLoader.load_data(@file_path)
  # end
end
