clc; 
close all;
clear all;

% Funções de Transferência Contínuas
Gs = tf(1,[1 1 0]); % Gs = (1/s(s+1))
Hs=tf(1,[1])      % Hs = 1  

% Período de amostragem
T = 1;
 
% Função de Transferência Discreta em malha aberta
Gz=c2d(Gs,T);    
Hz=c2d(Hs,T);      
GHz=c2d(Gs*Hs,T)

% Função de Transferência em malha fechada
FTMFa=minreal(Gz/(1+GHz))  % não é possivel usar o comando feedback

% Função de Transferência em malha fechada
FTMFb=feedback(Gz,Hz)  % ou  minreal(Gz/(1+Gz*Hz))

% Verificando a resposta do sistema para uma entrada do tipo degrau
% unitário com a função step
figure(1)
step(FTMFa);
 
%Resposta ao degrau
[sys,kT]= step(FTMFa);
hold on
plot(kT,sys,'ok');
axis([0,35,0,1.5]);
title('Resposta do sistema para uma entrada do tipo degrau unitário com a função step')

%Equação recursiva: c(k+2) = c(k+1)-0.6321c(k)+0.3679r(k+1)+0.2642r(k)
ck=zeros(1,length(kT));
%k=-1
ck(2) = 0.3679;
for k=1:length(kT)-2
   ck(k+2)= ck(k+1)-0.6321*ck(k)+0.3679+0.264;
end

hold on
plot(kT,ck,'*r');
title('Resposta do sistema para uma entrada do tipo degrau unitário utilizando a equação recursiva em malha fechada')
 
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
title('evolução temporal de c(kT)');
legend('G(s)','G(z)','Equação recursiva', 'Equação recursiva Ramo Direto');
