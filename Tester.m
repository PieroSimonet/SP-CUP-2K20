clear all;
close all;

x.a=randn(50,3);
x.b=randn(50,3);
for i=1:50
   [last, Anomalia,posizioneA,h, s]=IsolationForest(100,50,0.6,"a",x.a(i,:));
   disp(posizioneA);
%    [last2, Anomalia2,posizioneA2,h2, s2]=IsolationForest(100,20,0.6,"b",x.b(i,:));
%    disp(posizioneA2)
end
posizioneA=s>0.6;
plot3(x.a(:,1),x.a(:,2),x.a(:,3),'go','MarkerFaceColor','g','MarkerSize',12)
hold on

plot3(x.a(posizioneA,1),x.a(posizioneA,2),x.a(posizioneA,3),'ro','MarkerFaceColor','r','MarkerSize',12)
hold off
legend('Normal points','Anomalies')