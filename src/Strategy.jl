module Strategy
    export filter_elements!
        abstract type strategy end
        function filter_elements!(s::strategy)
            end
    println(methods(filter_elements!))        
end
