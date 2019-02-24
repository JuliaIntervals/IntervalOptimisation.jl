module StrategyBase

  export filter_elements!, Strategy
  abstract type Strategy end
  function filter_elements!(s::Strategy)end

end
