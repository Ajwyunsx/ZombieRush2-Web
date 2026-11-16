--vheadImage.lua

VHeadImage = VClass("HeadImage", VLayer)

function VHeadImage:Init(attr)
    self.headImage = VImage{name="headImage", layout="Center", fit="Fill", headImage=1};
    self.vipImgage = VImage{name="vipImage", layout="Up", fit={0.8, 0.3}, visible = 0};
    self.bgImgage = VImage{name="bgImage", layout="Up", fit={-1, 0}, visible = 0};
    self.vipTx = VText{name="vipTx", layout="Center", offset={0,11},font="tzvip.fnt"};
    self.vipImgage:Push(self.vipTx)
    self:Push(self.bgImgage);
    self:Push(self.headImage);
    self:Push(self.vipImgage);
    
    
    VLayer.Init(self, attr);
end

function VHeadImage:on_size(size)
	self.headImage:ReLayout();
end

function VHeadImage:on_image(image)
    self.headImage.image = image;
end

function VHeadImage:on_defaultImage(image)
    self.headImage.defaultImage = image;
end

function VHeadImage:setHead(userid, imageid, h, viplevel)
	self.headImage.image = gData:headImage(userid, imageid, h)
	if viplevel and userid ~= 10000 and userid ~= 1 and userid ~= 2 then
	    if viplevel == 0 then
            self.vipImgage.image = "vipbiaoshidi1.png"
            self.vipTx.text = "v"..(viplevel or 0)
	    else
            self.vipImgage.image = "vipbiaoshidi2.png"
            self.vipTx.text = "v"..(viplevel or 0)
	    end
	    
        self.vipImgage.visible = true
	end
end

function VHeadImage:SetHeadImageShader(imageName)
    local u_mask = {}
    u_mask.type = "sampler2D"
    u_mask.value = imageName or "zhezhao2.png"
    
    if u_mask.value == "zhezhao1.png" then
        
        self.bgImgage.image = "xiangkuangdi1.png"
        -- self.bgImgage.offset={0, 1}
        -- self.bgImgage.fit = {1, 1.025}
        self.bgImgage.visible = true
    elseif u_mask.value == "zhezhao2.png" then
        
        self.bgImgage.image = "xiangkuangdi2.png"
        -- self.bgImgage.offset={0, 0.5}
        -- self.bgImgage.fit = {1, 1.027}
        self.bgImgage.visible = true
    end

    local params = {};
    params.u_mask = u_mask
    self.headImage:Set_Shader("mask.fsh", ""..u_mask.value, true, params);
end