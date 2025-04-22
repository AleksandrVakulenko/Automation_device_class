

clc

dev = DLPCA200_dev(4);

pause(0.2)


[Current, Time_data, OVLD] = dev.get_current_value;
disp([num2str(Time_data, "%05.2f") ' ' num2str(OVLD) ' ' num2str(Current)]);

[Current, Time_data, OVLD] = dev.get_current_value;
disp([num2str(Time_data, "%05.2f") ' ' num2str(OVLD) ' ' num2str(Current)]);

[Current, Time_data, OVLD] = dev.get_current_value;
disp([num2str(Time_data, "%05.2f") ' ' num2str(OVLD) ' ' num2str(Current)]);


% pause(0.5)
delete(dev)
disp('END')


%% TEST PLOT DATA

clc

dev = DLPCA200_dev(4);
try
    figure
    Time_arr = [];
    Current_array = [];

    [~, Time_start] = dev.get_current_value;
    stop = false;
    while ~stop
        [Current, Time_data, OVLD] = dev.get_current_value;
        time = Time_data - Time_start;
        disp([num2str(time, "%05.1f") ' ' num2str(OVLD) ' ' num2str(Current)]);

        Time_arr = [Time_arr time];
        Current_array = [Current_array Current];

        cla
        plot(Time_arr, Current_array)
        drawnow

        if time > 10
            stop = true;
        end
    end

catch ERR
    delete(dev)
    rethrow(ERR)
end

delete(dev)
disp('END')




%% TEST SET SENSE



clc

dev = DLPCA200_dev(4);

% pause(0.2)

[sense, BW] = dev.set_sensitivity(4, "L")
% sense = dev.set_current_sensitivity(0.001);

% pause(0.5)
delete(dev)
disp('END')



















