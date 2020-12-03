clc
clear all
% Fun��o de Transfer�ncia Cont�nua

RC = 0.083;

Gs=tf((1),[RC 1])

% Per�odo de amostragem

T = 0.1;

% Fun��o de Transfer�ncia Discreta

Gz=c2d(Gs,T)

figure(1)
step(Gz);

%Resposta ao degrau
[sys,kT]= step(Gz);
hold on
plot(kT,sys,'*k');

b = 1 -exp(-T/RC)
a = exp(-T/RC)

num = [0.7003];
den = [1 -1.2997 0.2997];
[r,p,k] = residue(num,den)

% Equa��o recursiva: y(k+1) = 0.7003e(k) + 0.2997y(k)
yr = zeros(1,length(kT));
for k=1:length(kT)-1
    yr(k+1) = 0.7003 + 0.2997*yr(k);
end

hold on
plot(kT,yr,'ok');


%Equa��o exata: 
yex = zeros(1,length(kT));
yex(2:length(kT))= 1 - 0.2997.^(1:(length(kT)-1));
hold on
plot(kT,yex,'og');
xlabel('k')
ylabel('y(k)')
legend('G(s)','G(z)','Equa��o recursiva', 'Equa��o exata');
