
function Wait(time_s)

if time_s < 0.3
    disp(['Pause for ' num2str(round(time_s*100)/100) ' s']);
    pause(time_s)
else
    if time_s > 10
        Pause_time = 0.1;
    else
        Pause_time = 0;
    end
    Timer = tic;
    stop = false;
    while ~stop
        Time = toc(Timer);
        Time_disp = round(Time*100)/100;
        disp([num2str(Time_disp, '%0.2f') ' / ' num2str(time_s, '%0.2f')])
        pause(Pause_time);
        if Time > time_s
            stop = true;
        end
    end
end

end




