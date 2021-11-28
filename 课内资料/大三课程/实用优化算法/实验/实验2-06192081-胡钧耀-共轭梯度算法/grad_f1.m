function gf = grad_f1(x)
gf = [2*x(1) - 8*x(1)*(- x(1)^2 + x(2)) - 2;
    - 4*x(1)^2 + 4*x(2)];
end