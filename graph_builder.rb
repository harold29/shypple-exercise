# frozen_string_literal: true

require 'date'

require_relative 'node'
require_relative 'connection'

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
    nodes = {}

    @sailings.each do |sailing|
      origin_port = sailing['origin_port'].to_sym
      destination_port = sailing['destination_port'].to_sym

      unless nodes[origin_port]
        origin_node = Node.new(origin_port)
        nodes[origin_port] = origin_node

        graph ||= origin_node
      end

      unless nodes[destination_port]
        target_node = Node.new(destination_port)
        nodes[destination_port] = target_node
      end

      nodes[origin_port].connect_to(nodes[destination_port],
                                    departure_date: Date.parse(sailing['departure_date']),
                                    arrival_date: Date.parse(sailing['arrival_date']),
                                    rate: @rates[sailing['sailing_code'].to_sym][:rate],
                                    rate_currency: @rates[sailing['sailing_code'].to_sym][:rate_currency].to_sym,
                                    code: sailing['sailing_code'].to_sym)
    end

    nodes
  end
end
