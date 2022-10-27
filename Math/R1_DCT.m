clearvars; clc

% Símbolos
syms R1 dT TaMax TaMin Rs(T)

% Captura os extremos da equação
Umax = R1/(Rs(dT+TaMax)+R1);
Umin = R1/(Rs(dT+TaMin)+R1);

% Monta a diferença
dU = Umax-Umin;

% Deriva em relação a R1
dU_dR1 = diff(dU, R1);

% Máx. sens. de R1
R1 = solve( dU_dR1 == 0 , R1 );

disp("R1 = ")
pretty(R1) % Essa equação que permite o valor mais linear possível.

%% Plots
figure('color','w'); hold('on'); legend('show'); grid('on');
xlabel('Temperatura [°C]');
ylabel('V^-/V_o');

% Principais parâmetros
Ta = 0:.5:60;
B = 3700;
dT = 12;

% FT estática de R1
Rs = @(T) 330.*exp(B./(273.15+T) - B./298.15);

% Plota diversos valores
for R1 = 25:50:300
    y = R1./(Rs(Ta + dT) + R1);
    plot(Ta, y, 'DisplayName', ['R_1 = ',num2str(R1), ' Ω']);
end

% Plota o R1 ideal
R1_ideal = sqrt(Rs(Ta(1)+dT)*Rs(Ta(end)+dT));
y = R1_ideal./(Rs(Ta + dT) + R1_ideal);
plot(Ta, y,'LineWidth',2,'DisplayName', ['R_1 (ideal) = ',num2str(round(R1_ideal,1)), ' Ω']);
ylim([0 1]);