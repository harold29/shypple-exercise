class Node
  attr_accessor :location, :connections, :connection_hash

  def initialize(location)
    @location = location
    @connections = []
    @connection_hash = {}
  end

  def connect_to(target_node, departing_date:, arriving_date:, rate:, rate_currency:, code:)
    connection = Connection.new(self,
                                target_node,
                                departing_date:,
                                arriving_date:,
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
