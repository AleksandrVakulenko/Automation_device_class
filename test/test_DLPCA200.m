

clc

dev = DLPCA200_dev(4);

pause(0.2)


[Current, Time_data, OVLD] = dev.read_data
[Current, Time_data, OVLD] = dev.read_data
[Current, Time_data, OVLD] = dev.read_data

% pause(0.2)
% dev.read_last
% pause(0.2)
% dev.read_last
% pause(0.2)


% pause(0.5)
delete(dev)
disp('END')


%%



clc

dev = DLPCA200_dev(4);

pause(0.2)

figure
Time_arr = [];
Current_array = [];

Timer = tic;
stop = false;
while ~stop
    time = toc(Timer);
    if time > 10
        stop = true;
    end
    [Current, Time_data, OVLD] = dev.read_data;
%     disp([num2str(Time_data, "%0.2f") ' ' num2str(Current)]);
    disp([num2str(Time_data, "%0.2f") ' ' num2str(OVLD)]);
    
    Time_arr = [Time_arr Time_data];
    Current_array = [Current_array Current];
    
    cla
    plot(Time_arr, Current_array)
    drawnow

end




delete(dev)
disp('END')




%%




clc

dev = DLPCA200_dev(4);

pause(0.2)

[sense, BW] = dev.set_sensitivity(8, "L")

% pause(0.5)
delete(dev)
disp('END')



















