function i=checkgain_row(x)
sum = 0;
total = 0;
for k=1:5
    sum = sum+x(k);
    if x(k)==1
        total = total+k;
    end
end
if sum == 5
    i = 31;
elseif sum == 1
    for k=1:5
        i = total;
    end
elseif sum == 2
    if x(1)==1
        b = total-3;
        i = 6+b;
    elseif x(2)==1
        b = total-5;
        i = 10+b;
    elseif x(3)==1
        b = total-7;
        i = 13+b;
    elseif x(4)==1
        i = 15;
    end
    
elseif sum == 3
    if x(1)==1
        if total < 8
            b = total-6;
            i = 16+b;
        elseif total == 8
            if x(2) == 1
                i = 18;
            elseif x(3) == 1
                i = 19;
            end
        elseif total > 8
            b = total-9;
            i = 20+b;
        end
    elseif x(2)==1
        b = total-9;
        i = 22+b;
    elseif x(3)==1
        i =25;
    end
    
elseif sum == 4
    if x(1)==1
        b = total-10;
        i = 26+b;
    elseif x(2)==1
        i =30;
    end
    
end
end