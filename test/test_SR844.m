
DEBUG_MSG_ENABLE("disable")




%% AUTO TEST

clc

SR844 = SR844_dev(8);

% SR844.RESET;
% pause(5)

resp = SR844.get_IDN;
disp(['IDN: ' resp]);


SR844.set_time_constant(2.9)
SR844.get_time_constant()

Timer = tic;
for i = 1:50
    [X, Y] = SR844.data_get_XY;
    disp(['X = ' num2str(X) ' Y = ' num2str(Y)])
end
toc(Timer)

% ESR_struct = SR844.get_ESR;
% disp(ESR_struct)

%         fprintf('\n\n>>>>>CATCH ERROR>>>>>\n\n');
%         ESR_struct = SR860.get_ESR;
%         disp(ESR_struct)
%         fprintf('<<<<<END CATCH ERROR<<<<<\n\n\n');

delete(SR844)
disp('END')