
DEBUG_MSG_ENABLE("disable")




%% AUTO TEST

clc

SR844 = SR844_dev(8);

% SR844.RESET;
% pause(5)

% resp = SR844.get_IDN;
% disp(['IDN: ' resp]);


% SR844.set_time_constant(1);
% SR844.get_time_constant();


% for i = 1:10
% [X, Y] = SR844.data_get_XY;
% disp(['X = ' num2str(X) ' Y = ' num2str(Y)])
% end


SR844.get_ESR

delete(SR844)
disp('END')