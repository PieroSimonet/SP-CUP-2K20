clear all;
close all;

x=rand(100,2);
x(1,1)=2;

for i=1:20
   [Anomalie, data,h, s]=IsolationUpgrade(100,20,0.6,x(i,:));
   disp(s);
end
