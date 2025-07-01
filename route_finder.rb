# frozen_string_literal: true

require_relative 'graph_builder'
require_relative 'file_data_loader'

require 'json'

class RouteFinder
  def initialize(graph:, exchange_rates:)
    @graph = graph
    @exchange_rates = exchange_rates
  end

  def find(origin_code, destination_code, criteria)
    case criteria
    when 'cheapest-direct'
      find_cheapest_direct(origin_code, destination_code)
    when 'cheapest', 'fastest'
      result = dijkstra(origin_code, destination_code, criteria)
      return nil if result[:distance] == Float::INFINITY

      build_response(result)
    else
      raise ArgumentError, "Invalid criteria: #{criteria}"
    end
  end

  private

  def find_cheapest_direct(origin_code, destination_code)
    connections = @graph[origin_code].connection_hash[destination_code] || []
    return nil if connections.empty?

    cheapest = connections.min_by do |conn|
      rate = conn.rate.to_f
      currency = conn.rate_currency.to_s.downcase
      date = conn.departure_date.to_s
      rate_in_eur(rate, currency, date)
    end

    [format_connection(cheapest, include_code: true)]
  end

  def dijkstra(start, finish, criteria)
    distances = {}
    previous = {}
    visited = {}
    filled_connections = {}
    nodes = @graph.values

    nodes.each { |node| distances[node.location] = Float::INFINITY }
    distances[start] = 0

    until nodes.empty?
      min_node = nodes.min_by { |node| visited[node.location] ? Float::INFINITY : distances[node.location] }
      break if distances[min_node.location] == Float::INFINITY || min_node.location == finish

      visited[min_node.location] = true
      nodes.delete(min_node)

      @graph[min_node.location].connection_hash.each do |neighbor, connections|
        next if visited[neighbor]

        connections.each do |connection|
          cost = calculate_cost(connection, criteria)
          next if cost.nil?

          alt = distances[min_node.location] + cost
          if alt < distances[neighbor]
            distances[neighbor] = alt
            previous[neighbor] = min_node
            filled_connections[[min_node.location, neighbor]] = connection
          end
        end
      end
    end

    path = []
    current = finish
    while current
      path.unshift(current)
      current = previous[current]&.location
    end

    {
      distance: distances[finish],
      path: path,
      connections: filled_connections
    }
  end

  def calculate_cost(connection, criteria)
    case criteria
    when 'cheapest'
      rate = connection.rate.to_f
      currency = connection.rate_currency.to_s.downcase
      date = connection.departure_date.to_s
      rate_in_eur(rate, currency, date)
    when 'fastest'
      (connection.arrival_date - connection.departure_date).to_i
    end
  end

  def rate_in_eur(rate, currency, date)
    return rate if currency == 'eur'

    exchange_rate = @exchange_rates.dig(date, currency)
    return nil unless exchange_rate

    rate / exchange_rate
  end

  def format_connection(connection, include_code: false)
    output = {
      origin_port: connection.origin_node.location.to_s,
      destination_port: connection.target_node.location.to_s,
      departure_date: connection.departure_date.to_s,
      arrival_date: connection.arrival_date.to_s,
      rate: connection.rate,
      rate_currency: connection.rate_currency
    }
    output[:sailing_code] = connection.code if include_code
    output
  end

  def build_response(result)
    result[:path].each_cons(2).map do |from, to|
      connection = result[:connections][[from, to]]

      raise "Missing connection from #{from} to #{to}" unless connection

      format_connection(connection)
    end
  end
end
