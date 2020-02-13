clear all;
close all;

x=rand(20,2);
x(1,1)=3;

for i=1:20
   [Anomalie, data,h, s]=IsolationUpgrade(100,20,0.6,x(i,:));
   disp(s);
end
