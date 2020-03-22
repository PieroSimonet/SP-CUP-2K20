% tic
% InitTrees(true);
% a = toc;

% tic
% InitTrees();
% b = toc;

% disp(strcat('first: ', num2str(a,4)));
% disp(strcat('clean: ', num2str(b,4))); 

tm = TreesManager();
tm.disp();