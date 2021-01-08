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

%C�lculo do sobressinal(Mp)
disp('Mp: Sobre-Sinal da planta:')
Mp = delta1/delta2

%Calculo de Zeta a partir do Sobre-sinal
disp('Zeta: Fator de amortecimento da planta:')
zeta = sqrt(((log(Mp))^2)/(pi^2+(log(Mp))^2))

% C�lculo da freq��ncia n�o-amortecida da planta(Wn)    
disp('Wn: Frequ�ncia natural n�o amortecida da planta:')
Wn = pi/(tp*sqrt(1-zeta^2))

%C�lculo do Numerador
num = Wn^2;

%C�lculo do Denominador
den = [1 2*Wn*zeta Wn^2];

%C�lculo da Fun��o de Transfer�ncia da Planta
disp('Fun��o de Transfer�ncia da Planta G(s)')
G = tf(num,den)   

figure(1)
step(G)
title(' Fun��o de Transfer�ncia da Planta G(s)')

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

% C�lculo da freq��ncia n�o-amortecida do controlador digital(Wn) 
disp('Wn: Frequencia natural n�o amortecida do controlador digital:')
Wn = 3/(Ts5 * zeta)

% C�lculo da freq��ncia amortecida do controlador digital(Wd)
disp('Wd: Frequ�ncia natural amortecida do controlador digital:')
Wd = Wn * (sqrt(1-zeta^2))

% C�lculo do per�odo de amostragem (T)
% Uma boa pr�tica � adotar o Per�odo de Amostragem igual a
% 10 ou 15 vezes menos que o Tempo de Acomoda��o Ts5%
disp('Ta: Per�odo de Amostragem:')
T = Ts5 /15

% C�lculo da freq��ncia de amostragem (Ws)
disp('Ws: Frequ�ncia de amostragem desejada:')
Ws = (2*pi) / T

% C�lculo do n�mero de amostras (Na)
disp('Na: N�mero de amostras por ciclo de oscila��o:')
Na = Ws/Wd

% Aproximadamente 23 amostras por ciclo, o que � um valor 
% bastante satisfat�rio

%----------------------------------------------------------
%       C�lculo dos P�los de Malha Fechada Desejados 
%----------------------------------------------------------
%   Agora calculamos o p�lo no dom�nio s para posteriormente
%   mape�-lo no plano z seguindo a equa��o:
%    
%   Z = e^s*T
% 
%   Onde z � o p�lo em s convertido para o plano Z e T, o per�odo de 
%   amostragem.

s1 = -zeta*Wn + Wd*i
z1 = exp ( T * s1)

disp(' M�dulo de Z')
z1_modulo = exp( ((-2 * pi * zeta) / sqrt( 1 - zeta^2 )) * (Wd/Ws) )

disp(' �ngulo de Z em Graus')
z1_angulo = (2 * pi * Wd) / Ws
z1_angulo = rad2deg( z1_angulo )

figure(2)
zplane( 0, z1 )
grid
title(' P�lo de Malha Fechada Desejado no Plano Z ')


%   INICIO DO PROJETO DO CONTROLADOR DISCRETO

%----------------------------------------------------------
%       Fun��o de Transfer�ncia Discretizada da Planta G(z) 
%----------------------------------------------------------
disp(' Fun��o de Transfer�ncia Discreta G(z) ')
Gz = c2d( G, T, 'zoh' )
%0.0417
figure(3)
step(Gz)
title('Fun��o de Transfer�ncia Discretizada G(z)')

K = 0.0417

Gdz=tf(K*[1 0],[1 -1],T);

FTMF=feedback(Gdz*Gz,1);

figure(4)
step(FTMF)
figure(5)
rlocus(FTMF)