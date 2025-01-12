function [M] = calculateTorques(attitude)
global orbit_vec satellite
Ix = satellite.I(1,1); Iy = satellite.I(2,2); Iz = satellite.I(3,3);
%dcm
 Aorb2b = quat2DCM(attitude(1:4)');
 Aorb2b11 = Aorb2b(1,1);
 Aorb2b12 = Aorb2b(1,2);
 Aorb2b13 = Aorb2b(1,3);
 Aorb2b21 = Aorb2b(2,1);
 Aorb2b22 = Aorb2b(2,2);
 Aorb2b23 = Aorb2b(2,3);
 Aorb2b31 = Aorb2b(3,1);
 Aorb2b32 = Aorb2b(3,2);
 Aorb2b33 = Aorb2b(3,3);
%%
%aerodynamics
ro = Density(orbit_vec.h);
V = attitude(11:13);%circular velocity
Vx = V(1); Vy = V(2); Vz = V(3);
xa = satellite.ra(1); ya = satellite.ra(2); za = satellite.ra(3);
Vn = sqrt(Vx^2+Vy^2+Vz^2);
e_Vx = (Aorb2b11*Vx + Aorb2b12*Vy + Aorb2b13*Vz)/Vn; 
e_Vy = (Aorb2b21*Vx + Aorb2b22*Vy + Aorb2b23*Vz)/Vn; 
e_Vz = (Aorb2b31*Vx + Aorb2b32*Vy + Aorb2b33*Vz)/Vn; 
ka =  -0.5*ro* satellite.c0* satellite.Sm*Vn^2;
Max =ka*(ya*e_Vz-za*e_Vy);
May =ka*(za*e_Vx-xa*e_Vz);
Maz =ka*(xa*e_Vy-ya*e_Vx);
Ma = [Max; May; Maz];
%%
%gravity
e_Bx =  Aorb2b13; e_By =  Aorb2b23; e_Bz =  Aorb2b33; 
Mgx = 3*orbit_vec.w0^2*(Iz-Iy)*e_By*e_Bz;
Mgy = 3*orbit_vec.w0^2*(Ix-Iz)*e_Bx*e_Bz;
Mgz = 3*orbit_vec.w0^2*(Iy-Ix)*e_By*e_Bx;
%%all moments
Mx = Max+Mgx;
My = May+Mgy;
Mz = Maz+Mgz;
M = [Mx; My; Mz];
end