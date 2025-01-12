clear variables; clc;
global mu
        mu = 398600e+9; %gravitational constant
%%
%orbital elemets
%%
global orbit_vec
       orbit_vec.Re = 6371*1000; %earth radius
       orbit_vec.h = 400*1000; %height above sea level
       orbit_vec.sma =  orbit_vec.h+orbit_vec.Re; %semimajor axis
       orbit_vec.ecc = 0.0004; %eccentricity
       orbit_vec.inc = 51.64*pi/180; %inclination
       orbit_vec.raan = 10.752*pi/180; %right ascension of the ascending node
       orbit_vec.aop = 75.14*pi/180; %argument of perigee
       orbit_vec.ta = 115.95*pi/180; %truth anomaly
       orbit_vec.w0 = sqrt(mu/(orbit_vec.sma)^3); %mean motion

global satellite
       satellite.c0 = 2.2; %drag coefficient
       satellite.Sm = 0.1*0.3; %drag area
       satellite.ra = [0; 0.001; 0]; % center of mass shift
       satellite.I = diag([0.01, 0.01, 0.02]);
%%
statvec = kepel_statvec([orbit_vec.sma;
                         orbit_vec.ecc;
                         orbit_vec.inc;
                         orbit_vec.raan;
                         orbit_vec.aop;
                         orbit_vec.ta]);
%integrator
h = 1;%step
N = 1;
T = 2*pi*sqrt(orbit_vec.sma^3/mu);
t = 0:h:N*T;
x = zeros(length(t));
y = zeros(13,length(t));
%%initial conditions
y0 = [1 0 0 0 0 0 0 statvec]'; x0 = 0;
y(:,1) = y0; x(1) = x0;
%%integrating...
%%kalmaaaan F

[x,y] = ode4(@motionEquations,h,[0,N*T],[x0;y0]);
for i = 1:length(t)
    [a(i) b(i) c(i)] = quat2angle(y(1:4,i)','XYX');
    q_norm(i) = sqrt(y(1,i)^2+y(2,i)^2+y(3,i)^2+y(4,i)^2);
end

Aorb2b = quat2dcm(y(1:4,:)');
B_I = magneticField(y(8:10,:));
for j = 1:length(y)
    V = y(11:13,j);
    r = y(8:10,j);
    Ain2orb = inv([V/norm(V), cross(r,V)/norm(cross(r,V)), r/norm(r)]);
%     B_orb = Ain2orb*B_I(:,j);
%     B_b(:,j) = Aorb2b(:,:,j)*B_orb;
end

% B_b = awgn(B_b, 40,'measured');
w = awgn(y(5:7,:), 40,'measured');

%--------------------------------------------------------------------------

% figure;
% subplot(1,2,1); plot(x,a);xlabel("�����, �"); ylabel("���� ���������, �^-^1");grid;
% subplot(1,2,2); plot(x,b);xlabel("�����, �"); ylabel("���� �������, �^-^1");grid;
% 
% figure;
% subplot(1,2,1); plot(x,c);xlabel("Time,s"); ylabel("���� ���.��������, �^-^1");grid;
% subplot(1,2,2); plot(x, y(5,:)); xlabel("Time,s"); ylabel("w_x, ���/c"); grid;
% 
% figure;
% subplot(1,2,1); plot(x, y(6,:)); xlabel("Time,s"); ylabel("w_y, ���/c"); grid;
% subplot(1,2,2); plot(x, y(7,:)); xlabel("Time,s"); ylabel("w_z, ���/c"); grid;
% 
% figure; plot(x,q_norm); xlabel("Time,s"); ylabel("quaternion norm"); grid;
% 
% figure;
% plot3(y(8,:),y(9,:),y(10,:)); grid;

% figure;
% subplot(1,3,1); plot(x,B_b(1,:)*1e6);xlabel("�����, �"); ylabel("B_x, ����");grid;
% subplot(1,3,2); plot(x,B_b(2,:)*1e6);xlabel("�����, �"); ylabel("B_y, ����");grid;
% subplot(1,3,3); plot(x,B_b(3,:)*1e6);xlabel("�����, �"); ylabel("B_z, ����");grid;
figure;
subplot(1,3,1); plot(x, w(1,:)); xlabel("�����, �"); ylabel("w_x,  ���/c"); grid;
subplot(1,3,2); plot(x, w(2,:)); xlabel("�����, �"); ylabel("w_y,  ���/c"); grid;
subplot(1,3,3); plot(x, w(3,:)); xlabel("�����, �"); ylabel("w_z,  ���/c"); grid;

save('data.mat','x','y','h');