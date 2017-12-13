%part one : deploy environment

N = 20; %the number of user
M = 3;  %the number of small cell
r = 10; %max cover range

% (1)generate random user's location and small cell's location
ux = randperm(49); %user's location
ux = ux(1:N);
uy = randperm(49);
uy = uy(1:N);

sx = randi([10 40],1,M); %small cell location
sy = randi([10 40],1,M);

% (2)deploy small cell and UE
t = linspace(0,2*pi);
for i =1:N
    plot(ux(i),uy(i),'*');hold on;
end
for i=1:M
    plot(sx(i)+r*cos(t),sy(i)+r*sin(t),'r');hold on;
end
axis([0,50,0,50]);
xlabel('50m');
ylabel('50m');
set(gca,'xtick',(0:5:50),'ytick',(0:5:50));
title('Area');

%part two : adjust antenna beam pattern on/off

U = zeros(N,5*M); %U={u1,u2,..,uN},record user is covered by which R(i,j)
US = zeros(N,M); % record user is covered by which small cells
%UR = zeros(N,M); %record user is covered by which R(i,j),tens-->small cell/ units-->sector of small cell
R = zeros(M,5); %count R(i,j) for each user
X = zeros(M,5); %record beam pattern which is on

% (1)determine that UE is covered by which small cell
for i=1:N
    for j=1:M
        pos=[ux(i) uy(i);sx(j) sy(j)];
        d=pdist(pos,'euclidean');
        if d <=10
            US(i,j) = 1; % if cover-->set one
        end
    end
end
TUS = US';
B = zeros(1,M);%record the number of user in the small cell
for i=1:M
    for j=1:N
        if TUS(i,j)==1
            B(1,i) = B(1,i)+1;
        end
    end
end
%disp(B)

% (2) determine that UE is covered by which R(i,j)
D = zeros(N,M); %record  user's degree in small cell
for i=1:N
    for j=1:M
        if US(i,j)==1
            if ux(i) < sx(j) %left to the circle positive
                d=degree(ux(i),uy(i),sx(j),sy(j));
                D(i,j) = floor(d);
                if d > 108 %in R(i,3)
                    %UR(i,j) = j*10+3;
                    U(i,5*(j-1)+3) = 1;
                elseif d > 36 && d <= 108 %in R(i,2)
                    %UR(i,j) = j*10+2;
                    U(i,5*(j-1)+2) = 1;
                elseif d <= 36 %in R(i,1)
                    %UR(i,j) = j*10+1;
                    U(i,5*(j-1)+1) = 1;
                end
                
            elseif ux(i) > sx(j) %right to the circle negative
                d=degree(ux(i),uy(i),sx(j),sy(j));
                D(i,j) = 0-floor(d);
                if d > 108 %in R(i,4)
                    %UR(i,j) = j*10+4;
                    U(i,5*(j-1)+4) = 1;
                elseif d > 36 && d <= 108 %in R(i,5)
                    %UR(i,j) = j*10+5;
                    U(i,5*(j-1)+5) = 1;
                elseif d <= 36 %in R(i,1)
                    %UR(i,j) = j*10+1;
                    U(i,5*(j-1)+1) = 1;
                end
                %D = degree(i,j,ux,uy,sx,sy);
            elseif ux(i) == sx(j)  %in R(i,1)
                %UR(i,j)=j*10+1;
                d=degree(ux(i),uy(i),sx(j),sy(j));
                D(i,j) = floor(d);
                if uy(i) >= sy(j)
                    U(i,5*(j-1)+1) = 1;
                elseif uy(i) < sy(j)
                    U(i,5*(j-1)+4) = 1;
                end
            end
        end
    end
end
%disp(UR)
%disp(D)

% (3) determine which antenna should on/off X(i,j)
TU = U;
while sum(TU(:)) ~=0
    R = zeros(M,5);
    for i=1:N % count R(i,j) for each user
        for j=1:5*M
            if TU(i,j)==1
                q = ceil(j/5);
                R(q,(j-5*(q-1))) = R(q,(j-5*(q-1))) + 1;
            end
        end
    end
    %disp(R)
    maxval=max(R(:));
    %disp(maxval)
    for i=1:M % multiple max
        for j=1:5
            if R(i,j) == maxval
                X(i,j) = 1;
                R(i,j) = 0;
                for x=1:N
                    for y=1:5*M
                        if TU(x,5*(i-1)+j)==1
                            U(x,:) = 0;  %delet user which contain max R(i,j)
                            U(x,5*(i-1)+j) = 1; %selet only one area for user
                            TU(x,:) = 0;
                        end
                    end
                end
            end
        end
    end
end

%disp(U)

% part three : adjust power

%(1) initial variables
P = zeros(1,M); %small cell power
f = 2.3; %frequency band
noise = 4;
Band = 40;
large = 0;
power = zeros(1,M); %record final power alloation

%(2)adjust power
for p1=19:-1:-30
    for p2=19:-1:-30
        for p3=19:-1:-30
            P = [p1,p2,p3];
            Ob = 0; %objective function
            for i=1:N
                for j=1:5*M
                    if U(i,j)==1
                        %calculate snr_self(gain signal)
                        sn = ceil(j/5); % small cell number
                        pos=[ux(i) uy(i);sx(sn) sy(sn)];
                        d=pdist(pos,'euclidean'); %dk,si
                        b = Band/B(sn); %Bk
                        
                        %check antenna gain
                        dd = D(i,sn);
                        col = checkgain_col(dd); %table degree
                        row = checkgain_row(X(sn,:)); %table permutation
                        if dd>=0
                            gain = table_l(row,col);
                        else
                            gain = (table_r(row,col)+table_r(row,col+1))/2;
                        end
                        snr_self = P(sn)-(43.3*log10(d)+11.5+20*log10(f))+gain;
                        
                        %calculate snr_other(gain noise signal)
                        snr_other = 0;
                        for k=1:M
                            if k~=sn
                                pos=[ux(i) uy(i);sx(k) sy(k)];
                                dk=pdist(pos,'euclidean');
                                snr_other = P(k)-(43.3*log10(dk)+11.5+20*log10(f)) + snr_other;
                            end
                        end
                        snr_other = snr_other+noise;
                        
                        %calculate SNR
                        SNR = snr_self/snr_other;
                        SINR=10^(SNR/10); %transfer unit
                        cap = b*(log2(1+SINR));
                        Ob = Ob + cap;
                        %disp(Ob)
                    end
                end
            end
            if Ob > large
                large = Ob;
                power = [p1,p2,p3];
            end
        end
    end
end
% part four : deplace the result(Si,Xi)
disp('antenna on (Si,Xi)')
disp(X)
disp('transmission power of each small cell')
disp(power)

