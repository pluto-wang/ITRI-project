function d=degree(ux,uy,sx,sy)
     A = [sx-sx sy+10-sy];
     B = [ux-sx uy-sy];
     D = dot(A,B)/(norm(A)*norm(B)); % calculate degree
     d=rad2deg(acos(D));
end
