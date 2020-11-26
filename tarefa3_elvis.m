clc
clear
% Solução da equação recursiva
% solução exata -> y(k)
% y(0)=0; 
% Y(z)=( 10z + 5 ) / ( z^2 -1,2z + 0,2 )

% Método da frações parciais de Y(z)/z - Transformada Z inversa
% X(z)/z = ( 10z + 5 ) /( z^3 -1,2z^2 + 0,2z )
num = [10 5];
den = [1 -1.2 0.2 0];
[r,p,k] = residue(num,den)

% x(k) = 25?(k)-43,75(0,2)^k+18,75(1)^k

k = 0:20;
delta = zeros(1,length(k));
delta(1) = 1;   % para k=0

% solução exata
xe1 = 18.75*1.^k -43.75*0.2.^k;
xe = 25*delta+xe1;
plot(k,xe,'*')

hold on

% comportamento de x(k) a partir da equação recursiva
%y(k+1)-0,2y(k)=e(k)
%y(k+1)=e(k)+0,2y(k)
%yr(j+1)=u(j)+0,2*yr(j)

% entrada
u = delta;
% condições iniciais
yr(1) = 0;      % para k=0
yr(2) = 15;   
u(1)=10;

for i=2:length(k)
    u(i)=15;
end
for j = 1:length(k)-1
    yr(j+1)=u(j)+0.2*yr(j);
end

figure(1)   
plot(k,yr,'o')
xlabel('k')
ylabel('y(k)')
title('evolução temporal de y(k)')

hold off

u = [1 zeros(1,20)];
x = filter(num, den,u)