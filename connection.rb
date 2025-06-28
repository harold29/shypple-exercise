# frozen_string_literal: true

class Connection
  attr_accessor :origin_node,
                :target_node,
                :departing_date,
                :arriving_date,
                :rate,
                :code

  def initialize(origin_node, target_node, departing_date: , arriving_date:, rate:, rate_currency:, code:)
    @origin_node = origin_node
    @target_node = target_node
    @departing_date = departing_date
    @arriving_date = arriving_date
    @rate = rate
    @rate_currency = rate_currency
    @code = code
  end
end
