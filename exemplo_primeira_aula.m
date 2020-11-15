% exemplo_primeira_aula - Circuito RC
R = 1;
C = 1;
tau =  R*C;   % constante de tempo
% função de transfetência de primeira ordem
%    G(s) =  1 / (tau*s + 1)
num = 1;
den = [tau 1];
G = tf(num,den);

figure(1)
step(G)

% medindo o tempo de acomodação para 5 % (settlinf time) têm se o valor
% ts=3 segundos, três constantes de tempo

% Para alterar o comportamento do sistemas, considerando um novo tempo de
% acomodação  ts_novo e erro nulo em regime permanente para entreda do tipo degrau, podemos utilizar um controlador do tipo PI
ts_novo = 1;
% Controlador PI -> C(s) = Kp + Ki/s = Ki*(Kp/Ki*s+1)/s
% Cancelando o polo da planta com o zero do controlador
% temos Kp/Ki = tau
% A função de transferência de malha fechada é FTMF=1/(s/Ki+1)
% A nova constante de tempo é 1/Ki
% 1/Ki = ts_novo/3
Ki = 3;
Kp = 3;
C = tf([3 3],[1 0]);
FTMF = feedback(C*G,1);
zpk(FTMF)    % para verificar possíveis simplificações
FTMF = minreal(FTMF)

figure(2)
step(FTMF)

% pode se verificar os polos da FTMF
pole(FTMF)
FTLA=minreal(C*G);
figure(3)
rlocus(FTLA)
figure(4)
k=0:1/1000:2;
rlocus(FTLA,k)
% verifica se que para o valor de k=1 o valor do polo é igual a -3





