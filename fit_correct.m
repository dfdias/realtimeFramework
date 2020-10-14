function [f,x,y,r] = fit_correct(d,x_past,y_past,a1,a2,debug)

g = d';
XY = [real(g); imag(g)];%gera matriz para o hyperfix
P = HyperSVD(XY');%foi escolhido o svd por uma questão de estabildiade
x_present = P(1);
y_present = P(2);
x = a1*x_present + a2*x_past;
y = a1*y_present + a2*y_past;
r = P(3)
g_x = XY(1,:)-x;%centra o arco na origem
g_y = XY(2,:)-y;
g = g_x + 1*j*g_y;%gera o sinal complexo
g = arc_correct(g,debug);%correção de arco
f = g;

