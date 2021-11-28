function final = golden_section(funf, func, sigma, x, d)

epsilon = 1e-7;
a = 0;
b = 2;

alp1 = a + 0.382*(b-a);
alp2 = a + 0.618*(b-a);
while abs(b-a) > epsilon
    p1 = p(funf, func, sigma, alp1,x,d);
    p2 = p(funf, func, sigma, alp2,x,d);
    if p1 >= p2
        a = alp1;
        alp1 = alp2;
        alp2 = a + 0.618*(b-a);
    else
        b = alp2;
        alp2 = alp1;
        alp1 = a + 0.382*(b-a);
    end
end
final = (a+b) / 2;