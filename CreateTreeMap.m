function map = CreateTreeMap()
     
    map = containers.Map;
    map('voltage') = 'voltage';
    map('Current') = 'current';
    map('Power') = 'power';
    %map('Pos') = 'p_local';
    %map('Vel') = 'p_local';
    %map('Twi') = 'p_local';
    map('AngularVelocity') = 'v_ang';
    map('LinearAcceleration') = 'a_lin';
    map('v_gps') = 'v_gps';
    
    map('altitude') = 'altitude';
    map('pressure') = 'pressure';
    map('Temperature') = 'temperature';
    


end