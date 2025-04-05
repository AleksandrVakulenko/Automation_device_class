
function Wait(time_s, msg, disp_mode, Count_mode)
arguments
    time_s (1,1) {mustBeNumeric(time_s), mustBeGreaterThanOrEqual(time_s, 0)}
    msg (1,1) string = ""
    disp_mode {mustBeMember(disp_mode, ["silent", "normal"])} = "normal"
    Count_mode {mustBeMember(Count_mode, ["verbose", "eco"])} = "eco"
end

msg = char(msg);
if msg ~= ""
    msg = [' (' msg ')'];
end

if time_s < 0.3
    if disp_mode == "normal"
        disp(['Pause for ' num2str(round(time_s*100)/100) ' s' msg]);
    end
    pause(time_s)
else
    if Count_mode == "eco"
        Num_of_disp = 10;
        FMT = '%0.1f';
    else
        Num_of_disp = inf;
        FMT = '%0.2f';
    end
  
    Pause_time = time_s/Num_of_disp;

    Timer = tic;
    stop = false;
    while ~stop
        Time = toc(Timer);
        if Time > time_s
            stop = true;
        end
       
        if disp_mode == "normal"
            Time_disp = round(Time*100)/100;
            disp([num2str(Time_disp, FMT) ' / '...
                num2str(time_s, FMT) msg])
        end

        Last = time_s - Time;
        if Pause_time > Last
            Pause_time = Last*0.95;
        end

        pause(Pause_time);
    end
end

end




