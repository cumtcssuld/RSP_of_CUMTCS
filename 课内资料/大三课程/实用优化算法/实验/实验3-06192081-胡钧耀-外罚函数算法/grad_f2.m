function gf = grad_f2(x)
gf = [3*x(1) - x(2) + 1;
    2*x(2) - x(1) - x(3) + 1;
    x(3) - x(2) + 1];
end