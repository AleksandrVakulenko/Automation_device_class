
function Wait(time_s, msg, mode)
arguments
    time_s (1,1) {mustBeNumeric(time_s), mustBeGreaterThanOrEqual(time_s, 0)}
    msg (1,1) string = ""
    mode {mustBeMember(mode, ["silent", "normal"])} = "normal"
end

msg = char(msg);
if msg ~= ""
msg = [' (' msg ')'];
end

if time_s < 0.3
    if mode == "normal"
        disp(['Pause for ' num2str(round(time_s*100)/100) ' s' msg]);
    end
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
        if mode == "normal"
            disp([num2str(Time_disp, '%0.2f') ' / '...
                num2str(time_s, '%0.2f') msg])
        end
        pause(Pause_time);
        if Time > time_s
            stop = true;
        end
    end
end

end




