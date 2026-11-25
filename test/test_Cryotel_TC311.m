

COM_port_name = "";

Temp_dev = Cryotel_TC311(COM_port_name);




Test_Status = Test_01_f(Temp_dev);
if Test_Status
    disp('PASSED')
else
    disp('FAILS')
end

Test_Status = Test_02_f(Temp_dev);
if Test_Status
    disp('PASSED')
else
    disp('FAILS')
end

Test_Status = Test_03_f(Temp_dev);
if Test_Status
    disp('PASSED')
else
    disp('FAILS')
end

Test_Status = Test_04_f(Temp_dev);
if Test_Status
    disp('PASSED')
else
    disp('FAILS')
end

Test_Status = Test_05_f(Temp_dev);
if Test_Status
    disp('PASSED')
else
    disp('FAILS')
end


Test_06_f(Temp_dev);
Test_07_f(Temp_dev);




function Test_Status = Test_01_f(Temp_dev)
arguments
    Temp_dev adev_traits.Temp_ctrl_traits;
end
    disp([newline 'TEST: set_ramp_target()'])
    try
        % NOTE: this function is unavailable
        Temp_dev.set_ramp_target(50, "C");
        Test_Status = false;
        warning('Test fails: E01');
    catch err
        if err.identifier == "aDevice:Override:unable"
            Test_Status = true;
        else
            Test_Status = false;
            warning('Test fails: wrong error');
            rethrow(err);
        end
    end
end


function Test_Status = Test_02_f(Temp_dev)
arguments
    Temp_dev adev_traits.Temp_ctrl_traits;
end
    disp([newline 'TEST: set_ramp_rate()'])
    try
        % NOTE: this function is unavailable
        Temp_dev.set_ramp_rate(1, "K/min");
        Test_Status = false;
        warning('Test fails: E01');
    catch err
        if err.identifier == "aDevice:Override:unable"
            Test_Status = true;
        else
            Test_Status = false;
            warning('Test fails: wrong error');
            rethrow(err);
        end
    end
end


function Test_Status = Test_03_f(Temp_dev)
arguments
    Temp_dev adev_traits.Temp_ctrl_traits;
end
    disp([newline 'TEST: get_ramp_target()'])
    try
        % NOTE: this function is unavailable
        ramp_target = Temp_dev.get_ramp_target();
        Test_Status = false;
        warning('Test fails: E01');
    catch err
        if err.identifier == "aDevice:Override:unable"
            Test_Status = true;
        else
            Test_Status = false;
            warning('Test fails: wrong error');
            rethrow(err);
        end
    end
end


function Test_Status = Test_04_f(Temp_dev)
arguments
    Temp_dev adev_traits.Temp_ctrl_traits;
end
    disp([newline 'TEST: get_ramp_rate()'])
    try
        % NOTE: this function is unavailable
        ramp_rate = Temp_dev.get_ramp_rate();
        Test_Status = false;
        warning('Test fails: E01');
    catch err
        if err.identifier == "aDevice:Override:unable"
            Test_Status = true;
        else
            Test_Status = false;
            warning('Test fails: wrong error');
            rethrow(err);
        end
    end
end



function Test_Status = Test_05_f(Temp_dev)
arguments
    Temp_dev adev_traits.Temp_ctrl_traits;
end
    disp([newline 'TEST: set_setpoint() & get_setpoint()'])
    Set_point_value_C = 35; % [C]
    % NOTE: set new setpoint
    Temp_dev.set_setpoint(Set_point_value_C, "C");
    
    % NOTE: get current setpoint
    Setpoint = Temp_dev.get_setpoint();
    
    if (Setpoint - Set_point_value_C) > 0.001
        Test_Status = false;
    else
        Test_Status = true;
    end

end




function Test_06_f(Temp_dev)
arguments
    Temp_dev adev_traits.Temp_ctrl_traits;
end
    disp([newline 'MANUAL TEST: get_actual_temp()'])
    % NOTE: get measured temp
    Temp = get_actual_temp();
    
    disp(['Temp = ' num2str(Temp, '%0.3f') ' K'])
    disp('Is the value correct?')
end


function Test_07_f(Temp_dev)
arguments
    Temp_dev adev_traits.Temp_ctrl_traits;
end
    disp([newline 'MANUAL TEST: set_active()'])
    disp('Set setpoint to 0 [degC]')
    Temp_dev.set_setpoint(0, "C");
    
    % NOTE: enable PID and power output
    Temp_dev.set_active(true);
    disp('Heater and PID enabled')
    
    disp('Wait 10 sec')
    pause(10);
    
    % NOTE: disable PID and power output
    Temp_dev.set_active(false);
    disp('Heater and PID disabled')
end



