function g = arc_correct(g,r,debug)
cond = pi/2;

%%correção do arco
if debug == true
    figure(1);
    polarplot(angle(g),abs(g));
end
Q = angle(g);
Q = wrapTo2Pi(Q);
% %determinar o tamanho do arco
 [minValue,closestIndex] = min(abs(pi/2-Q))%encontra primeiro extremo do arco
 teta_min = Q(closestIndex)
% 
 [minValue,closestIndex] = min(abs((3*pi/2)-Q))%encontra primeiro extremo do arco
 teta_max = Q(closestIndex)


%calculates the length of the arc
[arc_len,seg_len] = arclength(real(g),imag(g),'spline')
arc_teta = arc_len/r

if teta_min > pi/2 && teta_max < 3*pi/2 %deteta se o arco está fora do primeiro ou quarto quadrantes
   rot = teta_min - arc_teta/2;
   g = g*exp(-1j * rot);%faz girar o arco
end   
if teta_min < pi/2 && teta_max > 3*pi/2 %deteta se o arco está dentro do primeiro ou quarto quadrantes
   rot = teta_min - arc_teta/2;
   g = g*exp(-1j * rot);%faz girar o arco
end   


if debug == true
    figure(10);
    polarplot(angle(g),abs(g));
end;