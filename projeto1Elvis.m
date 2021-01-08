%Projeto 1 Elvis
clc
clear all
close all

format long; 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%PLANTA

%Dados de entrada do projeto (delta1,delta2,tp)
delta1 = 0.144; %retirado da figura 
delta2 = 0.496; %retirado da figura 
tp = 0.0192;    %retirado da figura 

%Cálculo do sobressinal(Mp)
disp('Mp: Sobre-Sinal da planta:')
Mp = delta1/delta2

%Calculo de Zeta a partir do Sobre-sinal
disp('Zeta: Fator de amortecimento da planta:')
zeta = sqrt(((log(Mp))^2)/(pi^2+(log(Mp))^2))

% Cálculo da freqüência não-amortecida da planta(Wn)    
disp('Wn: Frequência natural não amortecida da planta:')
Wn = pi/(tp*sqrt(1-zeta^2))

%Cálculo do Numerador
num = Wn^2;

%Cálculo do Denominador
den = [1 2*Wn*zeta Wn^2];

%Cálculo da Função de Transferência da Planta
disp('Função de Transferência da Planta G(s)')
G = tf(num,den)   

figure(1)
step(G)
title(' Função de Transferência da Planta G(s)')

% NT = 42 (Elvis Roberto de Jesus Avila Carvalho Fernandes
NT = 0.042; 
Ts5 = NT;

% N = 5 (Elvis)
N = 5;
disp('Mp: Sobre-Sinal desejado:')
Mp = 2*N/100

% Calculo de Zeta desejado a partir do Sobre-sinal do controlador digital 
disp('Zeta: Fator de amortecimento desejado do controlador digital')
zeta = sqrt(((log(Mp))^2)/(pi^2+(log(Mp))^2))

% Cálculo da freqüência não-amortecida do controlador digital(Wn) 
disp('Wn: Frequencia natural não amortecida do controlador digital:')
Wn = 3/(Ts5 * zeta)

% Cálculo da freqüência amortecida do controlador digital(Wd)
disp('Wd: Frequência natural amortecida do controlador digital:')
Wd = Wn * (sqrt(1-zeta^2))

% Cálculo do período de amostragem (T)
% Uma boa prática é adotar o Período de Amostragem igual a
% 10 ou 15 vezes menos que o Tempo de Acomodação Ts5%
disp('Ta: Período de Amostragem:')
T = Ts5 /15

% Cálculo da freqüência de amostragem (Ws)
disp('Ws: Frequência de amostragem desejada:')
Ws = (2*pi) / T

% Cálculo do número de amostras (Na)
disp('Na: Número de amostras por ciclo de oscilação:')
Na = Ws/Wd

% Aproximadamente 23 amostras por ciclo, o que é um valor 
% bastante satisfatório

%----------------------------------------------------------
%       Cálculo dos Pólos de Malha Fechada Desejados 
%----------------------------------------------------------
%   Agora calculamos o pólo no domínio s para posteriormente
%   mapeá-lo no plano z seguindo a equação:
%    
%   Z = e^s*T
% 
%   Onde z é o pólo em s convertido para o plano Z e T, o período de 
%   amostragem.

s1 = -zeta*Wn + Wd*i
z1 = exp ( T * s1)

disp(' Módulo de Z')
z1_modulo = exp( ((-2 * pi * zeta) / sqrt( 1 - zeta^2 )) * (Wd/Ws) )

disp(' Ângulo de Z em Graus')
z1_angulo = (2 * pi * Wd) / Ws
z1_angulo = rad2deg( z1_angulo )

figure(2)
zplane( 0, z1 )
grid
title(' Pólo de Malha Fechada Desejado no Plano Z ')


%   INICIO DO PROJETO DO CONTROLADOR DISCRETO

%----------------------------------------------------------
%       Função de Transferência Discretizada da Planta G(z) 
%----------------------------------------------------------
disp(' Função de Transferência Discreta G(z) ')
Gz = c2d( G, T, 'zoh' )
%0.0417
figure(3)
step(Gz)
title('Função de Transferência Discretizada G(z)')

K = 0.0417

Gdz=tf(K*[1 0],[1 -1],T);

FTMF=feedback(Gdz*Gz,1);

figure(4)
step(FTMF)
figure(5)
rlocus(FTMF)