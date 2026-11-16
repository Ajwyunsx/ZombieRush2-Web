
VBattleRandom = vclass("BattleRandom")

VBattleRandom.MAX_NUMBER = 0x7FFF;

local local_bit = gBit;

function VBattleRandom:initialize(seed)
	self.RandomFacNumber = seed or math.floor(((os.time() * os.clock()) % VBattleRandom.MAX_NUMBER) + 1); 
end

function VBattleRandom:SetRandomSeed(seed)
	self.RandomFacNumber = seed
end

function VBattleRandom:NextIntNone()
    self.RandomFacNumber = local_bit:_and((self.RandomFacNumber * 214013 + 2531011), 0xffffffff);
    return local_bit:_and(local_bit:_rshift(self.RandomFacNumber, 16), VBattleRandom.MAX_NUMBER);
end

function VBattleRandom:NextInt(max) --range of result is [0, max)
	local temp = self:NextDouble() * max;
	--I approximate with the minimum integer value

	return math.floor(temp);
end

function VBattleRandom:NextDouble()
	local temp = self:NextIntNone() / (VBattleRandom.MAX_NUMBER + 1);
	return temp;				--range of result is [0, 1)
end

function VBattleRandom:NextBit()
	if self:NextDouble() >= 0.5 then
		return 1;
	else
		return 0;
	end
end

function VBattleRandom:RandBetween(from, to) --range of result is [from, to]
	return from + self:NextInt(to - from + 1);
end