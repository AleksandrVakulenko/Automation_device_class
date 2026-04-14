





% plot(temp - temp_sp)



histogram(temp - temp_sp, 10)




figure
hold on
plot(time, temp, 'b')
plot(time, temp_sp, 'r')
plot(time, temp_gsp, 'g')



%%

load('test_data.mat')

figure('position', [453 201 798 855])

% plot(lock)

range = logical(lock);
range2 = logical(lock) & logical(~ramping);


subplot(2,1,1)
hold on
plot(time, temp_gsp, '-k')
plot(time(range), temp(range), '.b')
plot(time(range2), temp(range2), '.c')
plot(time(~range), temp(~range), '.r','markersize',12)
plot(time, temp_sp, 'g')

min_sp = min(temp_sp);
max_sp = max(temp_sp);
span_sp = max_sp - min_sp;
ylim([min_sp-0.05*span_sp max_sp+0.05*span_sp])



delta = abs(temp - temp_sp);

subplot(2,1,2)
plot(time, movmean(delta, 2))
% yline(0.031);
% yline(0.04);
% yline(0.045);
yline(0.05);
set(gca,'yscale','log')








