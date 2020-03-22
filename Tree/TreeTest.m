% tic
% InitTrees(true);
% a = toc;

% tic
% InitTrees();
% b = toc;

% disp(strcat('first: ', num2str(a,4)));
% disp(strcat('clean: ', num2str(b,4))); 
map = containers.Map;
map('voltage') = 'voltage';
map('Pos') = 'p_local';

tm = TreesManager();
tm = tm.SetNameMap(map);
tm.disp();

tm = tm.PushData(data);
tm.disp();
