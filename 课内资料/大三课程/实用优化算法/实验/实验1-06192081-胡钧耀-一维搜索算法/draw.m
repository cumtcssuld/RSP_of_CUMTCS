function draw()
x=0:0.01:1;
y=-(sin(x)).^6.*tan(1-x).*exp(30*x);
subplot(2,1,1);
plot(x,y,'b-');
title('f1');

x=-1:0.01:2;
y=exp(-x) + exp(x);
subplot(2,1,2);
plot(x,y,'r-');
title('f2');
end