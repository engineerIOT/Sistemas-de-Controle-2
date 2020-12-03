clc; 
close all;
clear all;

% Fun��es de Transfer�ncia Cont�nuas
Gs = tf(1,[1 1 0]); % Gs = (1/s(s+1))
Hs=tf(1,[1])      % Hs = 1  

% Per�odo de amostragem
T = 1;
 
% Fun��o de Transfer�ncia Discreta em malha aberta
Gz=c2d(Gs,T);    
Hz=c2d(Hs,T);      
GHz=c2d(Gs*Hs,T)

% Fun��o de Transfer�ncia em malha fechada
FTMFa=minreal(Gz/(1+GHz))  % n�o � possivel usar o comando feedback

% Fun��o de Transfer�ncia em malha fechada
FTMFb=feedback(Gz,Hz)  % ou  minreal(Gz/(1+Gz*Hz))

% Verificando a resposta do sistema para uma entrada do tipo degrau
% unit�rio com a fun��o step
figure(1)
step(FTMFa);
 
%Resposta ao degrau
[sys,kT]= step(FTMFa);
hold on
plot(kT,sys,'ok');
axis([0,35,0,1.5]);
title('Resposta do sistema para uma entrada do tipo degrau unit�rio com a fun��o step')

%Equa��o recursiva: c(k+2) = c(k+1)-0.6321c(k)+0.3679r(k+1)+0.2642r(k)
ck=zeros(1,length(kT));
%k=-1
ck(2) = 0.3679;
for k=1:length(kT)-2
   ck(k+2)= ck(k+1)-0.6321*ck(k)+0.3679+0.264;
end

hold on
plot(kT,ck,'*r');
title('Resposta do sistema para uma entrada do tipo degrau unit�rio utilizando a equa��o recursiva em malha fechada')
 
cex=zeros(1,length(kT));
%k=-1
cex(2) = 0.3679;
for k=1:length(kT)-2
   cex(k+2)= 1.368*cex(k+1)-0.3679*cex(k)+0.3679*(1-cex(k+1))+0.2642*(1-cex(k));
end

hold on
plot(kT,cex,'*k');
axis([0,35,0,1.5]);
xlabel('kT');
ylabel('x(kT)');
title('evolu��o temporal de c(kT)');
legend('G(s)','G(z)','Equa��o recursiva', 'Equa��o recursiva Ramo Direto');
