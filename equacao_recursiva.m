% Exemplo de Algoritmo de Equações Recursivas
% Circuito RC
clc
clear
format long

Io = 16;            % valor inicial
T = .1;             % período de amostragem
RC = 0.14426951;    % constante RC
Tf = 2;             % tempo final de simulação
a = exp(-T/RC);


% Gráfico "contínuo" com 1000 pontos
t = 0:Tf/999:Tf;
I1 = Io*exp(-t/RC);
figure(1)
plot(t,I1)
hold on             % lembrar de hold off no final

% Gráfico discreto
k = 0:Tf/T;
I2 = Io*exp(-k*T/RC);
plot(k*T,I2,'*r')

% Gráfico discreto a partir da equação recursiva

% Condição Inicial
I3(1) = Io;   % para k = 0

for j=1:length(k)-1
    I3(j+1)=a*I3(j);
end
plot(k*T,I3,'ok')

% ou
% for j=2:length(k)
%     I3(j)=a*I3(j-1);
% end
% plot(k*T,I3,'ok')

hold off
