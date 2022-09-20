function gf = grad_f1(x)
gf = [2*x(1) - 4*x(2) + 4*(x(1) - 2)^3;
    8*x(2) - 4*x(1)];
end