function g = arc_correct(g,debug)
cond = pi/2;

%%correção do arco
if debug == true
    figure(1);
    polarplot(angle(g),abs(g));
end
Q = angle(g);
Q = wrapTo2Pi(Q);
%determinar o tamanho do arco
if length(find(Q > pi/2)) > 4
    teta_min = min(Q);
    teta_max = max(Q);
    arc_teta = max(Q)-min(Q);
%determina o minimo ângulo do arco
    rot = teta_min + arc_teta/2;
    g = g*exp(-1j * rot);%faz girar o arco
end
if debug == true
    figure(10);
    polarplot(angle(g),abs(g));
end;