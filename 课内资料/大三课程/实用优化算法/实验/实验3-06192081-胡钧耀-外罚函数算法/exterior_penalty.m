function [final_x, final_y] = exterior_penalty(funf, gradf, func, gradc, x)
epsilon = 10e-5;
sigma = 1;
k = 1;
stop = 0;
while stop == 0
    x = Conjugate_Gradient(funf, gradf, func, gradc, sigma, x);
    y = norm(func(x));
    if norm(func(x)) <= epsilon
        stop = 1;
    else
        sigma = 10 * sigma;
        k = k + 1;
    end
end
final_x = x;
final_y = funf(x);
