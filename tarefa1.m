clc
clear all
close all

format long; 

%----------------------------------------------------------
%            PPROJETO FINAL I DE CONTROLE DIGITAL 
%----------------------------------------------------------
% Autor: Victor Augusto dos Santos
%
%
%                       Tarefa I
%
% Objetivo: Aplicar conceitos de controle anal�gico/digital, para 
% o projeto de controladores digitais.
%
% Para o conversor abaixo da figura 1 (Anexo Folha_Tarefa), projetar
% e implementar um controlador digital para atingir as especifica��es
% abaixo.
% 
% Resposta ao degrau de refer�ncia de 9V a 10V
% Ts5% = Metade do valor obtido em Malha Aberta
% Erro M�ximo (ess) de 10% em regime permanente para resposta ao degrau
% MP = N%
% Estabilidade

% Par�metros nominais do conversor:
% Frequ�ncia de comuta��o: Fs = 20KHz
% Pot�ncia de sa�da: Po = 20W
% Tens�o de sa�da: Vo = 10V
% Tens�o de entrada: Vi = 24V
% Tens�o de pico do sinal triangular: Vs = 1V
% Indut�ncia de sa�da: Lo = NT*440uH
% Capacit�ncia de sa�da: Co = 1000uF
%
% Onde:
% 
% N = n�mero de letras do seu primeiro nome
% NT = n�mero de letras do seu nome completo
%
% Para o sistema proposto:
%
% 1. Elaborar um projeto de controlador discreto, no plano Z e testar os
% controladores.
% 2. Elaborar programas de simula��o no simulink, PSIM e no matlab (.m) que
% utilizem a implementa��o da equa��o a diferen�as atrav�s de blocos.
% 3. Entregar o relat�rio com os c�lculos utilizados, e as figuras dos
% testes dos controladores no matlab, simulink e PSIM.
% 4. Aplicar o teorema do valor final para verificar o erro em regime
% permanente e verifica��o em simula��o.
%
%

%----------------------------------------------------------
%                       METODOLOGIA 
%----------------------------------------------------------
% Este projeto segue os passos do Slide "Projeto de Controladores Digitais"
% fornecido pelo professor ministrante da disciplina, F�bio Alberto Badermaker
% Batista.
%
% O projeto � iniciado simulando o circuito do conversor no
% software de simula��o PSIM e extraindo da forma de onda de 
% sa�da do conversor, os valores necess�rios para montar a fun��o
% de transfer�ncia do circuito do conversor.
% Como a sa�da do conversar se trata de uma onda com caracter�sticas de
% segunda ordem (Sistema Sub-Amortecido), a fun��o de transfer�ncia seguir�
% o modelo de sistemas de segunda ordem:
%
% G(s) =              Wn^2
%          K * -------------------------
%               s^2 + 2*zeta*Wn + Wn^2
%
%----------------------------------------------------------
%                DADOS EXTRAIDOS DO PSIM 
%----------------------------------------------------------

%Tempo de Pico
tp = 0.00977;  %9.77ms

%deltaV1 � a varia��o da tens�o entre o momento de aplica��o do degrau
%e a tens�o em regime permanente 
deltaV1 = 1;

%deltaV2 � a varia��o entre a tens�o de pico e a tens�o em regime
%permanente
deltaV2 = 0.3877;

%Duty Cycle para a tens�o no momento do degrau  = 9V
%D1 = 9/Vin sendo Vin = 24V
D1 = 0.375;

%Duty Cycle para a tens�o em regime permanente - 10V
%D2 = 10/Vin
D2 = 0.416666;

%V1: Tens�o no momento do degrau
V1 = 9;

%V2: Tens�o em regime permanente
V2 = 10;

disp('MP: Sobre-Sinal:')
mp = deltaV2 / deltaV1

%mp = 0.3877

disp('Zeta: Fator de amortecimento:')
zeta = sqrt( ( (log(mp))^2 ) / ( pi^2 + (log(mp))^2) )

disp('Wn: Frequ�ncia natural n�o amortecida:')
Wn = pi/( tp * sqrt(1 - (zeta^2) ) )

disp('K: Ganho do sistema:')
K_planta = (V2 - V1) / ( D2 - D1 )

figure(1)
num_s = K_planta * ( Wn^2 );
den_s = [ 1 2*zeta*Wn Wn^2 ];
Gs = tf( num_s , den_s )
subplot( 2, 3, 1)
step(Gs)
grid
title(' Fun��o de Transfer�ncia da Planta G(s)')

%----------------------------------------------------------
% Com a fun��o de transfer�ncia da planta pronta (ainda n�o discretizada)
% mudei os par�metros usados Mp, ess e Ts5% para os valores requisitos de 
% projeto

%ts5%: Metade do valor obtido em malha aberta
ts5 = 3 / ( Wn * zeta ); % valor original
%ts5 = ts5/2     %original
ts5 = ts5/22     %ajuste para atender os requisitos de projeto ts5/NT
     

%MP : N%  sendo N o n�mero de letras do primeiro nome do autor
%mp = 0.06;        %victor ( 6 letras ) %original
mp = 0.02;         %ajuste feito para cair nos requisitos de projeto MP/3


%Erro em regime permanente (ess): 10%
% ess = 0.1;
% Kp = (1-ess)/ess;

%----------------------------------------------------------
% Daqui part� para a discretiza��o da planta G(s) criando a 
% fun��o de transfer�ncia j� com os par�metros recalculados para
% os requisitos de projeto
% Primeiramente definimos o Per�odo de Amostragem 

% Uma boa pr�tica � adotar o Per�odo de Amostragem igual a
% 10 ou 15 vezes menos que o Tempo de Acomoda��o Ts5%
disp('Pa: Per�odo de Amostragem:')
pa = ts5 / 10 


disp('Zeta: Fator de amortecimento:')
zeta = sqrt( ( (log(mp))^2 ) / ( pi^2 + (log(mp))^2 ));

disp('Wn: Frequencia natural n�o amortecida:')
Wn = 3 / ( ts5 * zeta )

disp('Wd: Frequ�ncia natural amortecida:')
Wd = Wn *( sqrt( 1 - zeta^2 ) )

disp('Ws: Frequ�ncia de amostragem:')
Ws = ( 2*pi ) / pa

disp('Na: N�mero de amostras por ciclo de oscila��o:')
nAmostras = Ws/Wd

% Aproximadamente 26 amostras por ciclo, o que � um valor 
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
z1 = exp ( pa * s1)

disp(' M�dulo de Z')
z1_modulo = exp( ((-2 * pi * zeta) / sqrt( 1 - zeta^2 )) * (Wd/Ws) )

disp(' �ngulo de Z em Graus')
z1_angulo = (2 * pi * Wd) / Ws
z1_angulo = rad2deg( z1_angulo )

subplot( 2, 3, 2 )
zplane( 0, z1 )
grid
title(' P�lo de Malha Fechada Desejado no Plano Z ')

%   INICIO DO PROJETO DO CONTROLADOR DISCRETO

%----------------------------------------------------------
%       Fun��o de Transfer�ncia Discretizada da Planta G(z) 
%----------------------------------------------------------
disp(' Fun��o de Transfer�ncia Discreta G(z) ')
Gz = c2d( Gs, pa, 'zoh' )

subplot(2,3,3)
step(Gz)
grid
title('Fun��o de Transfer�ncia Discretizada G(z)')

%----------------------------------------------------------
%       C�lculo da contribui��o angular 
%----------------------------------------------------------
% Com o p�lo desejado de malha fechada calculado (Z1), e com 
% os valores de p�los e zeros da fun��o discreta em m�os, podemos
% calcular a contribui��o angular, tomando o p�lo z1 como dominante.
% Existem duas maneiras de se fazer isso, ou se mapeia os p�los e zeros
% da fun��o G(z) no plano Z e se compara os �ngulos destes tendo como
% refer�ncia o p�lo dominante Z1 ou simplesmente se joga Z1 na fun��o de
% transfer�ncia discreta G(z1)
%
% Valendo ressaltar que como o controlador � do tipo avan�o de fase, �
% necess�rio criar mais uma rede de avan�o de fase se a contribui��o
% angular for maior que 90�

disp(' Aquisi��o do numerador e denominador de G(z) ')
[ num_Gz, den_Gz ] = tfdata(Gz,'v')

disp(' Substituindo z1 em G(z) -> G(z1) ')
Gz1 = polyval( num_Gz, z1 ) / polyval( den_Gz, z1 )

Gz1_angulo = rad2deg( angle(Gz1) )

disp('Contribuicao Angular:')
contribAngular = 180 - Gz1_angulo

% Se a contribui��o for maior que 90� se torna necess�rio incrementar a 
% ordem do compensador, de modo a criar mais uma rede de avan�o de fase

% Inicialmente temos um compensador por avan�o de fase de primeira ordem

comp_ordem = 1;

if ( contribAngular > 90 )
    disp(' ContribAngular > 90 ')
    contribAngular = contribAngular/2
    comp_ordem  = comp_ordem + 1
end

%----------------------------------------------------------
%       Modelo do Controlador: Avan�o de Fase 
%----------------------------------------------------------
%
%                Z + Alfa
%   Gc(z) =  K * --------  , onde K � o ganho do controlador        
%                Z + Beta
%
% Alfa pode ser definido como um dos p�los da fun��o
% da planta, para que possa ser posteriomente eliminado.

% Como sugerido pela refer�ncia, pegarei um dos p�los da fun��o
% discretizada G(z) que servir� de valor para o par�metro Alfa, de modo a
% cancel�-lo posteriormente

disp(' Extraindo os p�los de G(z)')
polosGz = roots( den_Gz )

disp(' Assimilando somente a parte real de um dos p�los em alfa ')

alfa = real(z1)

% Com o alfa calculado, partimos para o c�lculo do beta, utilizando
% recursos de trigonometria

aux1 = rad2deg( ( atan( ( alfa-real(z1) ) / imag( z1 ) ) ) )
beta = real( z1 ) - ( tan( deg2rad(contribAngular-aux1) ) ) * imag(z1)

% Com alfa e beta calculados, partimos para o c�lculo do ganho K do
% controlador atrav�s da Condi��o de M�dulo, para posteriormente montar a fun��o de transfer�ncia
% discretizada Gc(z)

disp(' K: Ganho do controlador ')
K = 1 / (abs(((z1-alfa)^2/(z1-beta)^2)*Gz1))


disp(' Fun��o de transfer�ncia do Controlador Gc(z) sem ganho ')
Gc = tf(conv([1 -alfa],[1 -alfa]),conv([1 -beta],[1 -beta]),pa)

disp(' Fun��o de transfer�ncia do Controlador Gc(z) com ganho: K*Gc(z) ')

KGc = K*Gc
zpk(KGc)

disp('Fun��o de transfer�ncia completa Gz(z)*KGc(z) com realimenta��o unit�ria ')
GMF = feedback(Gz*KGc,1)   

zpk( GMF )

%Por fim, aplicamos um degrau unit�rio no sistema completo para conferir o
%comportamento da sa�da

subplot(2, 3, 4)
step( GMF )
grid
title(' Aplica��o do degrau unit�rio na Planta Discreta Controlada em Malha Fechada GMF(z) ')

% Como pode-se observar no comportamento da sa�da, os valores de sobre-sinal
% e tempo de acomoda��o ts5% n�o correspondem aos requisitos de projeto.
% Isso se deve ao efeito do zero presente na fun��o de transfer�ncia do
% controlador Gc(z).
% O pr�ximo passo � projetar um filtro que cancele este zero e voltar a
% observar o comportamento de sa�da.

%----------------------------------------------------------
%       Projeto do filtro cancelador do efeito do zero (alfa) 
%----------------------------------------------------------
disp(' Filtro para cancelar o efeito do zero(alfa)')
[ num_a , num_b ] = tfdata( KGc, 'v' )
filtro = roots( num_a )
filtro1 = tf( [ (1 - filtro(1) ) ], [ 1 -filtro(1) ], pa )
filtro2 = tf( [ (1 - filtro(2) ) ], [ 1 -filtro(2) ], pa)

disp('Filtro F(z) ')
Fz = filtro1*filtro2

disp(' Sistema Completo com a adi��o do Filtro F(z): GMF(z)*F(z) ')
GzFull = GMF * Fz
subplot (2,3,5)
step(GzFull)
grid
title(' Aplica��o do Degrau no Sistema Completo com Filtro ')

% Pode-se observar que ap�s os ajustes necess�rios, o sistema completo com o
% filtro proporcionou uma resposta condizente com os requisitos de projeto, inclusive com valores
% mais baixos que os pr�prios requisitos

subplot(2,3,6)
rlocus(GzFull)
title(' Lugar da Ra�zes do Sistema Completo: Conferir p�los em Malha Fechada ')

% Com tudo funcionando de acordo com o esperado, partimos para o c�lculo de
% Valor Final e de Erro em Regime permanente, para nos assegurarmos que o
% sistema est� est�vel (tende a um valor finito) e que o valor de erro em
% regime est� dentro dos limites requisitados pelo projeto

%----------------------------------------------------------
%       Teorema do Valor Final 
%----------------------------------------------------------
disp(' Teorema do Valor Final ')

[ numSis, denSis ] = tfdata( GzFull, 'v' );
numVF = polyval( numSis, 1 );
denVF = polyval( denSis, 1 );
valorFinal = numVF/denVF
erroRegime = 1 / ( valorFinal + 1 )

