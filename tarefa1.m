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
% Objetivo: Aplicar conceitos de controle analógico/digital, para 
% o projeto de controladores digitais.
%
% Para o conversor abaixo da figura 1 (Anexo Folha_Tarefa), projetar
% e implementar um controlador digital para atingir as especificações
% abaixo.
% 
% Resposta ao degrau de referência de 9V a 10V
% Ts5% = Metade do valor obtido em Malha Aberta
% Erro Máximo (ess) de 10% em regime permanente para resposta ao degrau
% MP = N%
% Estabilidade

% Parâmetros nominais do conversor:
% Frequência de comutação: Fs = 20KHz
% Potência de saída: Po = 20W
% Tensão de saída: Vo = 10V
% Tensão de entrada: Vi = 24V
% Tensão de pico do sinal triangular: Vs = 1V
% Indutância de saída: Lo = NT*440uH
% Capacitância de saída: Co = 1000uF
%
% Onde:
% 
% N = número de letras do seu primeiro nome
% NT = número de letras do seu nome completo
%
% Para o sistema proposto:
%
% 1. Elaborar um projeto de controlador discreto, no plano Z e testar os
% controladores.
% 2. Elaborar programas de simulação no simulink, PSIM e no matlab (.m) que
% utilizem a implementação da equação a diferenças através de blocos.
% 3. Entregar o relatório com os cálculos utilizados, e as figuras dos
% testes dos controladores no matlab, simulink e PSIM.
% 4. Aplicar o teorema do valor final para verificar o erro em regime
% permanente e verificação em simulação.
%
%

%----------------------------------------------------------
%                       METODOLOGIA 
%----------------------------------------------------------
% Este projeto segue os passos do Slide "Projeto de Controladores Digitais"
% fornecido pelo professor ministrante da disciplina, Fábio Alberto Badermaker
% Batista.
%
% O projeto é iniciado simulando o circuito do conversor no
% software de simulação PSIM e extraindo da forma de onda de 
% saída do conversor, os valores necessários para montar a função
% de transferência do circuito do conversor.
% Como a saída do conversar se trata de uma onda com características de
% segunda ordem (Sistema Sub-Amortecido), a função de transferência seguirá
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

%deltaV1 é a variação da tensão entre o momento de aplicação do degrau
%e a tensão em regime permanente 
deltaV1 = 1;

%deltaV2 é a variação entre a tensão de pico e a tensão em regime
%permanente
deltaV2 = 0.3877;

%Duty Cycle para a tensão no momento do degrau  = 9V
%D1 = 9/Vin sendo Vin = 24V
D1 = 0.375;

%Duty Cycle para a tensão em regime permanente - 10V
%D2 = 10/Vin
D2 = 0.416666;

%V1: Tensão no momento do degrau
V1 = 9;

%V2: Tensão em regime permanente
V2 = 10;

disp('MP: Sobre-Sinal:')
mp = deltaV2 / deltaV1

%mp = 0.3877

disp('Zeta: Fator de amortecimento:')
zeta = sqrt( ( (log(mp))^2 ) / ( pi^2 + (log(mp))^2) )

disp('Wn: Frequência natural não amortecida:')
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
title(' Função de Transferência da Planta G(s)')

%----------------------------------------------------------
% Com a função de transferência da planta pronta (ainda não discretizada)
% mudei os parâmetros usados Mp, ess e Ts5% para os valores requisitos de 
% projeto

%ts5%: Metade do valor obtido em malha aberta
ts5 = 3 / ( Wn * zeta ); % valor original
%ts5 = ts5/2     %original
ts5 = ts5/22     %ajuste para atender os requisitos de projeto ts5/NT
     

%MP : N%  sendo N o número de letras do primeiro nome do autor
%mp = 0.06;        %victor ( 6 letras ) %original
mp = 0.02;         %ajuste feito para cair nos requisitos de projeto MP/3


%Erro em regime permanente (ess): 10%
% ess = 0.1;
% Kp = (1-ess)/ess;

%----------------------------------------------------------
% Daqui partí para a discretização da planta G(s) criando a 
% função de transferência já com os parâmetros recalculados para
% os requisitos de projeto
% Primeiramente definimos o Período de Amostragem 

% Uma boa prática é adotar o Período de Amostragem igual a
% 10 ou 15 vezes menos que o Tempo de Acomodação Ts5%
disp('Pa: Período de Amostragem:')
pa = ts5 / 10 


disp('Zeta: Fator de amortecimento:')
zeta = sqrt( ( (log(mp))^2 ) / ( pi^2 + (log(mp))^2 ));

disp('Wn: Frequencia natural não amortecida:')
Wn = 3 / ( ts5 * zeta )

disp('Wd: Frequência natural amortecida:')
Wd = Wn *( sqrt( 1 - zeta^2 ) )

disp('Ws: Frequência de amostragem:')
Ws = ( 2*pi ) / pa

disp('Na: Número de amostras por ciclo de oscilação:')
nAmostras = Ws/Wd

% Aproximadamente 26 amostras por ciclo, o que é um valor 
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
z1 = exp ( pa * s1)

disp(' Módulo de Z')
z1_modulo = exp( ((-2 * pi * zeta) / sqrt( 1 - zeta^2 )) * (Wd/Ws) )

disp(' Ângulo de Z em Graus')
z1_angulo = (2 * pi * Wd) / Ws
z1_angulo = rad2deg( z1_angulo )

subplot( 2, 3, 2 )
zplane( 0, z1 )
grid
title(' Pólo de Malha Fechada Desejado no Plano Z ')

%   INICIO DO PROJETO DO CONTROLADOR DISCRETO

%----------------------------------------------------------
%       Função de Transferência Discretizada da Planta G(z) 
%----------------------------------------------------------
disp(' Função de Transferência Discreta G(z) ')
Gz = c2d( Gs, pa, 'zoh' )

subplot(2,3,3)
step(Gz)
grid
title('Função de Transferência Discretizada G(z)')

%----------------------------------------------------------
%       Cálculo da contribuição angular 
%----------------------------------------------------------
% Com o pólo desejado de malha fechada calculado (Z1), e com 
% os valores de pólos e zeros da função discreta em mãos, podemos
% calcular a contribuição angular, tomando o pólo z1 como dominante.
% Existem duas maneiras de se fazer isso, ou se mapeia os pólos e zeros
% da função G(z) no plano Z e se compara os ângulos destes tendo como
% referência o pólo dominante Z1 ou simplesmente se joga Z1 na função de
% transferência discreta G(z1)
%
% Valendo ressaltar que como o controlador é do tipo avanço de fase, é
% necessário criar mais uma rede de avanço de fase se a contribuição
% angular for maior que 90º

disp(' Aquisição do numerador e denominador de G(z) ')
[ num_Gz, den_Gz ] = tfdata(Gz,'v')

disp(' Substituindo z1 em G(z) -> G(z1) ')
Gz1 = polyval( num_Gz, z1 ) / polyval( den_Gz, z1 )

Gz1_angulo = rad2deg( angle(Gz1) )

disp('Contribuicao Angular:')
contribAngular = 180 - Gz1_angulo

% Se a contribuição for maior que 90º se torna necessário incrementar a 
% ordem do compensador, de modo a criar mais uma rede de avanço de fase

% Inicialmente temos um compensador por avanço de fase de primeira ordem

comp_ordem = 1;

if ( contribAngular > 90 )
    disp(' ContribAngular > 90 ')
    contribAngular = contribAngular/2
    comp_ordem  = comp_ordem + 1
end

%----------------------------------------------------------
%       Modelo do Controlador: Avanço de Fase 
%----------------------------------------------------------
%
%                Z + Alfa
%   Gc(z) =  K * --------  , onde K é o ganho do controlador        
%                Z + Beta
%
% Alfa pode ser definido como um dos pólos da função
% da planta, para que possa ser posteriomente eliminado.

% Como sugerido pela referência, pegarei um dos pólos da função
% discretizada G(z) que servirá de valor para o parâmetro Alfa, de modo a
% cancelá-lo posteriormente

disp(' Extraindo os pólos de G(z)')
polosGz = roots( den_Gz )

disp(' Assimilando somente a parte real de um dos pólos em alfa ')

alfa = real(z1)

% Com o alfa calculado, partimos para o cálculo do beta, utilizando
% recursos de trigonometria

aux1 = rad2deg( ( atan( ( alfa-real(z1) ) / imag( z1 ) ) ) )
beta = real( z1 ) - ( tan( deg2rad(contribAngular-aux1) ) ) * imag(z1)

% Com alfa e beta calculados, partimos para o cálculo do ganho K do
% controlador através da Condição de Módulo, para posteriormente montar a função de transferência
% discretizada Gc(z)

disp(' K: Ganho do controlador ')
K = 1 / (abs(((z1-alfa)^2/(z1-beta)^2)*Gz1))


disp(' Função de transferência do Controlador Gc(z) sem ganho ')
Gc = tf(conv([1 -alfa],[1 -alfa]),conv([1 -beta],[1 -beta]),pa)

disp(' Função de transferência do Controlador Gc(z) com ganho: K*Gc(z) ')

KGc = K*Gc
zpk(KGc)

disp('Função de transferência completa Gz(z)*KGc(z) com realimentação unitária ')
GMF = feedback(Gz*KGc,1)   

zpk( GMF )

%Por fim, aplicamos um degrau unitário no sistema completo para conferir o
%comportamento da saída

subplot(2, 3, 4)
step( GMF )
grid
title(' Aplicação do degrau unitário na Planta Discreta Controlada em Malha Fechada GMF(z) ')

% Como pode-se observar no comportamento da saída, os valores de sobre-sinal
% e tempo de acomodação ts5% não correspondem aos requisitos de projeto.
% Isso se deve ao efeito do zero presente na função de transferência do
% controlador Gc(z).
% O próximo passo é projetar um filtro que cancele este zero e voltar a
% observar o comportamento de saída.

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

disp(' Sistema Completo com a adição do Filtro F(z): GMF(z)*F(z) ')
GzFull = GMF * Fz
subplot (2,3,5)
step(GzFull)
grid
title(' Aplicação do Degrau no Sistema Completo com Filtro ')

% Pode-se observar que após os ajustes necessários, o sistema completo com o
% filtro proporcionou uma resposta condizente com os requisitos de projeto, inclusive com valores
% mais baixos que os próprios requisitos

subplot(2,3,6)
rlocus(GzFull)
title(' Lugar da Raízes do Sistema Completo: Conferir pólos em Malha Fechada ')

% Com tudo funcionando de acordo com o esperado, partimos para o cálculo de
% Valor Final e de Erro em Regime permanente, para nos assegurarmos que o
% sistema está estável (tende a um valor finito) e que o valor de erro em
% regime está dentro dos limites requisitados pelo projeto

%----------------------------------------------------------
%       Teorema do Valor Final 
%----------------------------------------------------------
disp(' Teorema do Valor Final ')

[ numSis, denSis ] = tfdata( GzFull, 'v' );
numVF = polyval( numSis, 1 );
denVF = polyval( denSis, 1 );
valorFinal = numVF/denVF
erroRegime = 1 / ( valorFinal + 1 )

