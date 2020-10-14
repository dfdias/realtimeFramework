clear all
clc

f= 10
n = 2
ocb = circularbuffer(f,n)

for i = 1 : 40
    a = randn(1,n)
    ocb.appends(a)
    idx = ocb.getorder()
    buffer = ocb.buffer()
    a = ocb.buffer(:,idx)
    a(:)
    pause
end



