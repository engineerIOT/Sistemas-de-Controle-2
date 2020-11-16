% Aluno: Elvis Fernandes
% Data: 15/11/2020
% Exemplo de Algoritmo de Equa��es Recursivas
% Circuito RC
clc
clear
format long

Io = 1;             % valor inicial
T = 0.005;          % per�odo de amostragem
NT = 42;            % numero de letras de meu nome inteiro
C = 0.001;          % capacitor 1000uF
RC = NT*C;          % constante RC
Tf = NT*0.01;       % tempo final de simula��o
a = exp(-T/RC);
e = 10;             %tens�o

% Gr�fico "cont�nuo" com 1000 pontos
t = 0:Tf/999:Tf;
b = 1 - Io*exp(-t/RC);

plot(t,a+(b*e))
hold on             % lembrar de hold off no final





