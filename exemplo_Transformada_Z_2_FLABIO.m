% Exemplo 2 da apresenta��o sobre Transformada Z
% slides 36 e 39
clc
clear
% Solu��o da equa��o recursiva
% solu��o exata -> x(k)
% x(0)=0; x(1)=0
% X(z)=1/(z^2-3z+2)

% M�todo da fra��es parciais de X(z)/z - Transformada Z inversa
% X(z)/z=1/(z^3-3z^2+2z)
n = 1;
d = [1 -3 2 0];
[r,p,k] = residue(n,d)

% x(k) = 0.5*delta(k)-1*1^k+0.5*2^k

k = 0:10;
delta = zeros(1,length(k));
delta(1) = 1;   % para k=0

% solu��o exata
xe1 = -1*1.^k+0.5*2.^k;
xe = 0.5*delta+xe1;
plot(k,xe,'*')

hold on

% comportamento de x(k) a partir da equa��o recursiva
% x(k+2)-3x(k+1)+2x(k)=u(k)
% u(k) = pulso unit�rio (delta(k))

% entrada
u = delta;
% condi��es iniciais
xr(1) = 0;      % para k=0
xr(2) = 0;   

for j = 1:length(k)-2
    xr(j+2) = u(j)+3*xr(j+1)-2*xr(j);
end

figure(1)
plot(k,xr,'o')

hold off


