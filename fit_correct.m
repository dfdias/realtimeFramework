function [f,x,y,r] = fit_correct(d,x_past,y_past,r_past,axy,ar,filter_handle,debug)

g = d';
XY = [real(g); imag(g)];%gera matriz para o hyperfix
P = HyperSVD(XY');%foi escolhido o svd por uma questão de estabildiade
x_present = P(1);
y_present = P(2);
r_present = P(3);
x = axy*x_present + (1-axy)*x_past;
y = axy*y_present + (1-axy)*y_past;
r = ar*r_present + (1-ar)*r_past;
r = P(3);
g_x = XY(1,:)-x;%centra o arco na origem
g_y = XY(2,:)-y;
g = g_x + 1*j*g_y;%gera o sinal complexo
g = arc_correct(g,filter_handle,debug);%correção de arco
f = g;

