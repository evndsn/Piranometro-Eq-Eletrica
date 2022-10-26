% Reset do matlab
clearvars; clc

%% Principais parâmetros
Ta = 0:60;				% Define a variação da temperatura ambiente [°C]
Hmax = 1600; 			% Define a máxima radiação incidente [W/m^2]
alpha = 15E-6;			% Define o coeficiente de calibração
Gth = 2E-3;				% Define o fator de dissipação do sensor quente [°C]
dT = Hmax * alpha/Gth;	% Diferença de temperatura ideal

% Constrói as funções estáticas dos sensores quente e frio
Rsq = @(T) 331.*exp(3700./(T+273.15) - 3700/298.15);
Rsf = @(T) 30E3.*exp(3600./(T+273.15) - 3600/298.15);

% Calcula o valor de R1 ideal
R1 = sqrt(Rsq(Ta(1) + dT)*Rsq(Ta(end) + dT));

% Define o sistema não linear
F = @(R) [R1.*(Rsf(Ta(1))*R(4)/(Rsf(Ta(1))+R(4)) + R(2) + R(3)) - (Rsq(Ta(1)+dT) + R1).*R(2) + Vos;
          R1.*(Rsf(mean(Ta))*R(4)/(Rsf(mean(Ta))+R(4)) + R(2) + R(3)) - (Rsq(mean(Ta)+dT) + R1).*R(2) + Vos;
          R1.*(Rsf(Ta(end))*R(4)/(Rsf(Ta(end))+R(4)) + R(2) + R(3)) - (Rsq(Ta(end)+dT) + R1).*R(2) + Vos;
          double(R(2) <= 0)*1E9;	% Penaliza resistência negativa ou zero
          double(R(3) < 0)*1E9; 	% Penaliza resistência negativa
          double(R(4) < 0)*1E9; 	% Penaliza resistência negativa
          ];

% Opções do otimizador
opt = optimoptions('fsolve','algorithm','Levenberg-Marquardt', ...
                    'Display','iter-detailed', ...
                    'MaxIterations',5E5,'MaxFunctionEvaluations',3E4);
					
% Chute inicial de valores
R0 = [0, 30E3, 200, 10E4];

% Resolve o sistema 
[R, fval] = fsolve(F,R0,opt);

% Extrai os valores
R2 = R(2); R3 = R(3); R4 = R(4);

% Monta as funções de transf. do ramo quente e frio
Hq = R1./(Rsq(Ta+dT) + R1);
Hf = R2./(Rsf(Ta).*R4./(Rsf(Ta)+R4)+R3+ R2);

fprintf('R1: %.2f %c | R2: %.2f %c | R3: %.2f %c | R4: %.2f %c\nFit: %.2f%%\n', R1, 937, R2,937,R3,937,R4,937,...
        100*(1-mean(((Hq-Hf)./(Hq+Hf)).^1)));

% Cria a Figura
f=figure(1);
set(f,'color','w');
plot(Ta, Hq, Ta, Hf);
legend({'Ramo quente','Ramo frio'},'Location','best');
xlabel('Temperatura [°C]'); grid on;
ylabel('V_{out}/V_{in}');