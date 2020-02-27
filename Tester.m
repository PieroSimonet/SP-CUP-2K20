clear all;
close all;

x.a=rand(20,2);
x.a(5,1)=3;
x.b=rand(20,2);
for i=1:20
   [last, Anomalia,posizioneA,h, s]=IsolationForest(100,20,0.7,"a",x.a(i,:));
   disp(s);
   [last2, Anomalia2,posizioneA2,h2, s2]=IsolationForest(100,20,0.7,"b",x.b(i,:));
   disp(s2)
end

