function g = arc_correct(g,debug)
cond = pi/2;

%%correção do arco
if debug == true
    figure(1);
    polarplot(angle(g),abs(g));
end
Q = angle(g);
a = unwrap(Q);
m = mean(a);
g = g*exp(-j*m);

if debug == true
    figure(10);
    polarplot(angle(g),abs(g));
end;