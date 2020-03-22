f = @test;


t1 = tree('')

t = tree('root');
[ t node1 ] = t.addnode(1, f);
[ t node2 ] = t.addnode(node1, 'N 2');
[ t node3 ] = t.addnode(1, 'N 3');

disp(t.tostring)

disp(' ');
disp(' ');
disp(' ');

%t = t.removenode(node1);
ff = t.get(node1);
% disp(ff(1));

disp(t.depthfirstiterator)
disp(t.breadthfirstiterator)

function out =  test(a,b,c)

    % if no argument is passed, display description
    if(nargin == 0)
        out = 'function description';
        return;
    end
    
    % else 
    out = a;
    
end