function [finalX, finalY, times] = golden_section(func, a, b, epsilon)
left = a + 0.382*(b-a);
right = a + 0.618*(b-a);
times = 1;
while abs(b-a) > epsilon
    f1 = func(left);
    f2 = func(right);
    if f1 >= f2
        a = left;
        left = right;
        right = a + 0.618*(b-a);
    else
        b = right;
        right = left;
        left = a + 0.382*(b-a);
    end
    times = times + 1;
    draw(a,b,x_asterisk)
end
finalX = (a+b) / 2;
finalY = func(finalX);