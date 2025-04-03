
clc

dev = FG120_dev(15);

dev.set_freq(10.9)
dev.get_freq()

disp('1')
dev.bad_foo
disp('2')

delete(dev)







