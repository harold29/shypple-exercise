# frozen_string_literal: true

class Connection
  attr_accessor :origin_node,
                :target_node,
                :departure_date,
                :arrival_date,
                :rate,
                :rate_currency,
                :code

  def initialize(origin_node, target_node, departure_date: , arrival_date:, rate:, rate_currency:, code:)
    raise ArgumentError, 'origin_node and target_node must be different' if origin_node == target_node
    raise ArgumentError, 'departure_date must be before arrival_date' if departure_date >= arrival_date
    raise ArgumentError, 'rate must be positive' if rate.to_f <= 0

    @origin_node = origin_node
    @target_node = target_node
    @departure_date = departure_date
    @arrival_date = arrival_date
    @rate = rate
    @rate_currency = rate_currency
    @code = code
  end
end
