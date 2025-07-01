class Node
  attr_accessor :location, :connections, :connection_hash

  def initialize(location)
    if location.nil? || (location.is_a?(String) && location.strip.empty?)
      raise ArgumentError, 'location is required'
    end

    @location = location
    @connections = []
    @connection_hash = {}
  end

  def connect_to(target_node, departure_date:, arrival_date:, rate:, rate_currency:, code:)
    connection = Connection.new(self,
                                target_node,
                                departure_date:,
                                arrival_date:,
                                rate:,
                                rate_currency:,
                                code:
                              )

    @connections << connection

    if @connection_hash[target_node.location]
      @connection_hash[target_node.location] << connection
    else
      @connection_hash[target_node.location] = [connection]
    end
  end
end
