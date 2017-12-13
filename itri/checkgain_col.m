function j=checkgain_col(d)
if d>=0
    if mod(d,2)==0
        j = (d/2)+1;
    else
        j = ((d-1)/2)+1;   
    end
else
    if mod(d,2)==0
        j = abs(d/2)+1;
    else
        j = ((abs(d)-1)/2)+1;
    end
end
end