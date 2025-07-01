# frozen_string_literal: true

require_relative 'graph_builder'
require_relative 'file_data_loader'
require_relative 'route_finder'

loaded_file = FileDataLoader.load_data('response.json')
graph = GraphBuilder.build_graph(loaded_file.sailings, loaded_file.rates)
exchange_rates = loaded_file.exchange_rates
finder = RouteFinder.new(graph: graph, exchange_rates: exchange_rates)

while true
  origin_code = gets.chomp.to_sym
  destination_code = gets.chomp.to_sym
  criteria = gets.chomp

  begin
    result = finder.find(origin_code, destination_code, criteria)
    if result.nil? || result.empty?
      puts "No route found from #{origin_code} to #{destination_code}"
    else
      puts JSON.generate(result)
    end
  rescue ArgumentError => e
    puts e.message
  end
end
