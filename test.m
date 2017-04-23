% tester
clear;
clc;

A = [.1; .2; .3; .4; .5]


product = 1.0;
for i = 1:length(A)
    product = product * A(i, 1);
end

matlab = prod(A)
me = product