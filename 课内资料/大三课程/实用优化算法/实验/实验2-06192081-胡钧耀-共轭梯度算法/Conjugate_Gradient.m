function [x_star,val,k]=Conjugate_Gradient(fun,grad_fun,x_old)
epsilon=1e-5;
n = length(x_old);
beta = 0;
d = 0;
k = 0;

f = feval(fun,x_old);
g = feval(grad_fun,x_old);

if norm(g) <= epsilon
    run = 0;
else
    run = 1;
end

while run == 1 && k <= 10000
    d = -g+beta*d;
    alpha = golden_section(fun, x_old, d);
    x_new = x_old + alpha*d;
    g = feval(grad_fun,x_old);
    if norm(g) <= epsilon
        run = 0;
    else 
        if mod(k,n+1) == 0
            beta = 0;
        else
            beta = norm(feval(grad_fun,x_new))^2/norm(feval(grad_fun,x_old))^2;
        end
        k = k + 1;
        x_old = x_new;
    end
end
x_star = x_old;
val=feval(fun,x_star);