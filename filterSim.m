%% This Matlab file simulates the second-order low-pass filter that is used
% to filter motor pulses to provide a clean tachometer signal. This filter
% is implemented with analog components and is therefore continuous. The 
% Matlab continuous control systems tools are used for the simulation.

% ------\/\/\/---|---\/\/\/---|------
%         R1     |     R2     |
%               ---          ---
%            C1 ---       C2 ---
%                |            |
% -----------------------------------

% Motor parameters
n_poles = 12;
rpm = 1000;
pwm_freq = 18000; % Hz
voltage = 11.0;

% Filter parameters
R1 = 10000; % ohms
C1 = 10e-9; % farads
R2 = 10000; % ohms
C2 = 10e-9; % farads

s = tf('s');

sys = 1 / (1 + R1*C1*s) / (1 + R2*C2*s);

t = 0.000001:0.000001:0.003;
square_wave = ( sin(pwm_freq*2*pi*t) > 0 );
signal = voltage*sin((rpm/60*n_poles/2)*2*pi*t).*square_wave;

noise = randn(size(signal));

signal = signal + noise;

clf;
plot(t,signal,'r-');
hold on;
%plot(t,square_wave,'b-');

y = lsim(sys,signal,t);

output = (y > 0)*5;

plot(t,y,'b-');
plot(t,output,'g-');