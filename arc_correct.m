function phi = arc_correct(g,filterobj,debug)

phi = angle(g);
phi = unwrap(phi);%tribolet
phi = filter(filterobj.B,filterobj.A,phi); %filtragem passo a alto

if debug == true
    figure(10);
    polarplot(phi,1);
    title("Arco após correção")
end;