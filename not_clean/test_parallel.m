parpool(2);      % Call to open the distributed processing
x = zeros(100,10);          % Initialize the main variable
parfor i = 1:100            % Parallel loop
     y = zeros(1,10);       % Initialize the secondary variable
     for j = 1:10           % Inner loop
         y(j) = i;
     end
     y                      % Display the inner variable (note the random execution about "i" in the command window)
     x(i,:) = y;            % Get values from loop into the main variable
end
x                           % Display main variable
delete(gcp);