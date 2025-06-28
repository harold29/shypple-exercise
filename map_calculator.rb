# frozen_string_literal: true

require_relative 'graph_builder'
require_relative 'file_data_loader'

def dijkstra(graph, start, end_node, criteria)
  distances = {}
  previous = {}
  visited = {}
  nodes = graph.keys

  nodes.each { |node| distances[node] = Float::INFINITY }
  distances[start] = 0

  until nodes.empty?
    min_node = nodes.min_by { |node| visited[node] ? Float::INFINITY : distances[node] }

    break if distances[min_node] == Float::INFINITY
    break if min_node == end_node

    visited[min_node] = true
    nodes.delete(min_node)

    graph[min_node].connection_hash.each do |neighbor, connections|
      next if visited[neighbor]

      best_connection = nil
      best_cost = Float::INFINITY

      connections.each do |connection|
        case criteria
        when 'cheapest'
          cost = connection.rate
        when 'fastest'
          cost = (connection.arriving_date - connection.departing_date).to_i
        else
          next
        end

        if cost < best_cost
          best_cost = cost
          best_connection = connection
        end
      end

      next unless best_connection

      alt = distances[min_node] + best_cost
      if alt < distances[neighbor]
        distances[neighbor] = alt
        previous[neighbor] = min_node
      end
    end
  end
end

loaded_file = FileDataLoader.load_data('response.json')
graph = GraphBuilder.build_graph(loaded_file.sailings, loaded_file.rates)
exchange_rates = loaded_file.exchange_rates

while true
  origin_code = gets.chomp.to_sym
  destination_code = gets.chomp.to_sym
  criteria = gets.chomp

  puts origin_code
  puts destination_code

  case criteria
  when 'cheapest-direct'
    puts 'cheapest-direct'
  when 'cheapest'
    puts 'cheapest'
  when 'fastest'
    puts 'fastest'
  else
    puts 'Invalid criteria'
  end
end
