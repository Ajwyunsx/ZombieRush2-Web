--bit operation

bit = {};
bit.data64 = {};

for i=1,64 do
    bit.data64[i]=2^(64-i)
end

function bit:d2b(arg)
    if not arg then
        cclog("***** arg = nil");
    end 
    local   tr={}
    for i=1,64 do
        if arg >= self.data64[i] then
        tr[i]=1
        arg=arg-self.data64[i]
        else
        tr[i]=0
        end
    end
    return   tr
end   --bit:d2b

function    bit:b2d(arg)
    local   nr=0
    for i=1,64 do
        if arg[i] ==1 then
        nr=nr+2^(64-i)
        end
    end
    return  nr
end   --bit:b2d

function    bit:_xor(a,b)
    local   op1=self:d2b(a)
    local   op2=self:d2b(b)
    local   r={}

    for i=1,64 do
        if op1[i]==op2[i] then
            r[i]=0
        else
            r[i]=1
        end
    end
    return  self:b2d(r)
end --bit:xor

function    bit:_and(a,b)
    local   op1=self:d2b(a)
    local   op2=self:d2b(b)
    local   r={}
    
    for i=1,64 do
        if op1[i]==1 and op2[i]==1  then
            r[i]=1
        else
            r[i]=0
        end
    end
    return  self:b2d(r)
    
end --bit:_and

function    bit:_or(a,b)
    local   op1=self:d2b(a)
    local   op2=self:d2b(b)
    local   r={}
    
    for i=1,64 do
        if  op1[i]==1 or   op2[i]==1   then
            r[i]=1
        else
            r[i]=0
        end
    end
    return  self:b2d(r)
end --bit:_or

function    bit:_not(a)
    local   op1=self:d2b(a)
    local   r={}

    for i=1,64 do
        if  op1[i]==1   then
            r[i]=0
        else
            r[i]=1
        end
    end
    return  self:b2d(r)
end --bit:_not

function    bit:_rshift(a,n)
    local   op1=self:d2b(a)
    local   r=self:d2b(0)

    if n < 64 and n > 0 then
        for i=64, n+1, -1 do
            op1[i] = op1[i-n]
        end
        
        for i=1, n do
            op1[i] = 0
        end
    end
    
    r = op1
    return  self:b2d(r)
end --bit:_rshift

function    bit:_lshift(a,n)
    local   op1=self:d2b(a)
    local   r=self:d2b(0)

    if n < 64 and n > 0 then
        for i=1,64-n do
            op1[i]=op1[i+n]
        end

        for i = 64, 64-n+1, -1 do
            op1[i] = 0;
        end
    end

    r = op1
    return  self:b2d(r)
end --bit:_lshift


function    bit:print(ta)
    local   sr=""
    for i=1,64 do
        sr=sr..ta[i]
    end
    print(sr)
end

--end of bit.lua