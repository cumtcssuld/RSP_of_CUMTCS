function gpx = grad_p(gradf, func, gradc, x, sigma)
gfx=gradf(x);
cx=func(x);
gcx=gradc(x);
gpx=gfx+2*sigma*gcx*cx;
end