import ForwardDiff: gradient, jacobian, hessian

gradient(f, X::IntervalBox) = gradient(f, X.v)
# jacobian(f, X::IntervalBox) = jacobian(f, X.v)
hessian(f, X::IntervalBox) = hessian(f, X.v)

"""
Calculate the mean-value form of a function ``f:\\mathbb{R}^n \\to \\mathbb{R}``
using the gradient ``\nabla f``;
this gives a second-order approximation.
"""
function mean_value_form_scalar(f, X)
    m = IntervalBox(mid(X))

    return f(m) + gradient(f, X.v) ⋅ (X - m)
end

mean_value_form_scalar(f) = X -> mean_value_form_scalar(f, X)


"""
Calculate a third-order Taylor form of ``f:\\mathbb{R}^n \\to \\mathbb{R}`` using the Hessian.
"""
function third_order_taylor_form_scalar(f, X)
    m = IntervalBox(mid(X))

    H = hessian(f, X)
    δ = X - m

    return f(m) + gradient(f, m) ⋅ δ + 0.5 * sum(δ[i]*H[i,j]*δ[j] for i in 1:length(X) for j in 1:length(X))
end

third_order_taylor_form_scalar(f) = X -> third_order_taylor_form_scalar(f, X)
