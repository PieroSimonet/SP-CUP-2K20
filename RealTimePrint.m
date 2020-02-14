function [] = RealTimePrint(data,time,graphicNumber)
%REALTIMEPRINT Summary of this function goes here
%   Detailed explanation goes here

    persistent placeholder;

    if isempty(placeholder)
        placeholder(1) = graphicNumber;
        initializeGraphic(graphicNumber);
        setUpData(data,time);
    end

    isFindedPrecedentGraphicNumber = false;
    for i = 1:length(placeholder)
        if placeholder(i) == graphicNumber
            isFindedPrecedentGraphicNumber = true;
        end 
    end

    if not(isFindedPrecedentGraphicNumber)
        placeholder(length(placeholder) + 1) = graphicNumber;
        initializeGraphic(graphicNumber);
        setUpData(data,time);
    end

    figure(graphicNumber)
    refreshdata
    drawnow

end

function [] = initializeGraphic(placeholder)
    figure(placeholder)
    % xlim([0, 20]);
    % ylim([-20, 20]);
    hold on;
    grid on;
end

function p = setUpData(data,time)
    for i = 1 : length(data)
        p{i} = plot(time,data{i},'-o');
        p{i}.YDataSource = ['data{' num2str(i) '}'];
        p{i}.XDataSource = 'time';
    end
end
