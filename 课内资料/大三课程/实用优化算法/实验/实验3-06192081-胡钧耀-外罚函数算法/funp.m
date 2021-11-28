function px = funp (funf, func, x, sigma)
fx=funf(x);
cx=func(x);
px=fx+sigma*cx'*cx;
end

