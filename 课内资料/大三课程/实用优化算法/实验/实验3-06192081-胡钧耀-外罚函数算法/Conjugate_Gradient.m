function x_star = Conjugate_Gradient(funf, gradf, func, gradc, sigma, x_old)

epsilon_1 = 1e-7;
n = length(x_old);
beta = 0;
d = 0;
kk = 0;

f = funp(funf, func, x_old, sigma);
g = grad_p(gradf, func, gradc, x_old, sigma);

if norm(g) <= epsilon_1
    run = 0;
else
    run = 1;
end

while run == 1 && kk < 10000
    d = -g+beta*d;
    alpha = golden_section(funf, func, sigma, x_old, d);
    x_new = x_old + alpha*d;
    g = grad_p(gradf, func, gradc, x_new, sigma);
    if norm(g) <= epsilon_1
        run = 0;
    else 
        if mod(kk,n+1) == 0
            beta = 0;
        else
            beta = norm(grad_p(gradf, func, gradc, x_new, sigma))^2/norm(grad_p(gradf, func, gradc, x_old, sigma))^2;
        end
        kk = kk + 1;
        x_old = x_new;
    end
end
x_star = x_old;