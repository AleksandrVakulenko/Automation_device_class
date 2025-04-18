

clc

dev = DLPCA200_dev(4);

pause(0.2)


[Current, Time_data, OVLD] = dev.read_data;
disp([num2str(Time_data, "%05.2f") ' ' num2str(OVLD) ' ' num2str(Current)]);

[Current, Time_data, OVLD] = dev.read_data;
disp([num2str(Time_data, "%05.2f") ' ' num2str(OVLD) ' ' num2str(Current)]);

[Current, Time_data, OVLD] = dev.read_data;
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

    [~, Time_start] = dev.read_data;
    stop = false;
    while ~stop
        [Current, Time_data, OVLD] = dev.read_data;
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

pause(0.2)

[sense, BW] = dev.set_sensitivity(8, "L")

% pause(0.5)
delete(dev)
disp('END')



















