module Binance::Responses
  # Typical server response
  #     {
  #       "filterType":"MARKET_LOT_SIZE",
  #       "minQty":"0.00000000",
  #       "maxQty":"63100.00000000",
  #       "stepSize":"0.00000000"
  #     }
  #
  # The MARKET_LOT_SIZE filter defines the quantity (aka "lots" in auction terms) rules for MARKET
  # orders on a symbol. There are 3 parts:
  #
  # minQty defines the minimum quantity allowed.
  # maxQty defines the maximum quantity allowed.
  # stepSize defines the intervals that a quantity can be increased/decreased by.
  # In order to pass the market lot size, the following must be true for quantity:
  #
  # quantity >= minQty
  # quantity <= maxQty
  # (quantity-minQty) % stepSize == 0
  #
  class MarketLotSizeFilter < ExchangeFilter
    @[JSON::Field(key: "minQty", converter: Binance::Converters::ToFloat)]
    getter min_quantity : Float64 = 0.0

    @[JSON::Field(key: "maxQty", converter: Binance::Converters::ToFloat)]
    getter max_quantity : Float64 = 0.0

    @[JSON::Field(key: "stepSize", converter: Binance::Converters::ToFloat)]
    getter step_size : Float64 = 0.0

    def decimals
      ((1.0 / step_size).to_i.to_s.size - 1)
    end

    def validate(value : Float64)
      Array(String).new.tap do |errors|
        errors << "#{value} is below min_quantity of #{min_quantity}" if min_quantity > 0 && value <= min_quantity
        errors << "#{value} exceeds max_quantity of #{max_quantity}" if max_quantity > 0 && value >= max_quantity
        errors << "#{value} is an invalid step_size #{step_size}" if step_size > 0 && value.round(decimals) != value
      end
    end

    def valid?(value : Float64)
      validate(value).empty?
    end
  end
end
