function [] = RealTimePrint(data,time)
%REALTIMEPRINT Summary of this function goes here
%   Detailed explanation goes here
persistent placeholder;
if isempty(placeholder)
    placeholder = 1;
    figure(placeholder)
    xlim([0, 100]);
    ylim([0, 100]);
    p = plot(time,data, '-o');
    p.XDataSource = 'time';
    p.YDataSource = 'data';
    % xlim([0, 100]);
    ylim([0, 20]);
   
    grid on;
end

figure(placeholder)
refreshdata
drawnow

