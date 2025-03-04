
DEBUG_MSG_ENABLE("enable")

clc

SR860 = SR860_dev(15);

% a = SR860.set_gen_freq(20)
% SR860.get_gen_freq;
% [a,b,c] = SR860.set_gen_amp(1.1)
% SR860.get_gen_amp;
[a,f] = SR860.set_generator(1,10)

delete(SR860)










