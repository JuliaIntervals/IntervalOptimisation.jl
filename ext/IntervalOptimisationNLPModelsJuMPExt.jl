module IntervalOptimisationNLPModelsJuMPExt

using IntervalOptimisation
using NLPModelsJuMP: MathOptNLPModel
import MathOptInterface as MOI
import NLPModels

function IntervalOptimisation._make_objective(nlp::MathOptNLPModel, nvar)
    if nlp.obj.type == "NONLINEAR"
        obj_expr = MOI.objective_expr(nlp.eval)
        if nvar == 1
            return x -> IntervalOptimisation._eval_moi_expr(obj_expr, [x])
        else
            return x -> IntervalOptimisation._eval_moi_expr(obj_expr, x)
        end
    else
        # For LINEAR/QUADRATIC, NLPModels.obj works directly with intervals
        if nvar == 1
            return x -> NLPModels.obj(nlp, [x])
        else
            return x -> NLPModels.obj(nlp, x)
        end
    end
end

end
