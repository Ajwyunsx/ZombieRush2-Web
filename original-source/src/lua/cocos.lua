--cocos.lua

function cc.p(_x,_y)
    if nil == _y then
         return { x = _x.x, y = _x.y }
    else
         return { x = _x, y = _y }
    end
end

function cc.pAdd(pt1,pt2)
    return {x = pt1.x + pt2.x , y = pt1.y + pt2.y }
end

function cc.pSub(pt1,pt2)
    return {x = pt1.x - pt2.x , y = pt1.y - pt2.y }
end

function cc.pMul(pt1,factor)
    return { x = pt1.x * factor , y = pt1.y * factor }
end

function cc.pGetLength(pt)
    return math.sqrt( pt.x * pt.x + pt.y * pt.y )
end

function cc.pMidpoint(pt1,pt2)
    return { x = (pt1.x + pt2.x) / 2.0 , y = ( pt1.y + pt2.y) / 2.0 }
end

--Size
function cc.size( _width,_height )
    return { width = _width, height = _height }
end

--Rect

function cc.rectZero()
    return cc.rect(0,0,0,0);
end

function cc.rect(_x,_y,_width,_height)
    return { x = _x, y = _y, width = _width, height = _height }
end

function cc.rectGetMaxX(rect)
    return rect.x + rect.width
end

function cc.rectGetMidX(rect)
    return rect.x + rect.width / 2.0
end

function cc.rectGetMinX(rect)
    return rect.x
end

function cc.rectGetMaxY(rect)
    return rect.y + rect.height
end

function cc.rectGetMidY(rect)
    return rect.y + rect.height / 2.0
end

function cc.rectGetMinY(rect)
    return rect.y
end

--Color3B
function cc.c3b( _r,_g,_b )
    return { r = _r, g = _g, b = _b }
end

--Color4B
function cc.c4b( _r,_g,_b,_a )
    return { r = _r, g = _g, b = _b, a = _a }
end

--Color4F
function cc.c4f( _r,_g,_b,_a )
    return { r = _r, g = _g, b = _b, a = _a }
end

function cc.rectContainsPoint( rect, point )
    local ret = false
    
    if (point.x >= rect.x) and (point.x <= rect.x + rect.width) and
       (point.y >= rect.y) and (point.y <= rect.y + rect.height) then
        ret = true
    end

    return ret
end

function cc.rectContainsPoint1( rect, point, ratio, deviation )
    local ret = false

--    if (point.x >= rect.x) and (point.x <= rect.x + rect.width) and
--        (point.y >= rect.y) and (point.y <= rect.y + rect.height) then
--        ret = true
--    end

    if ((point.y - rect.height + rect.height * deviation.y) * (0 - rect.width * (1 - ratio.x)) - (point.x - rect.width * (1 - ratio.x) - rect.width * deviation.x) * (rect.height * (ratio.y - 1))) > 0 and  --判断菱形左上斜边,平行四边形则为左斜边,(x2,y2)为上定点
        ((point.y - rect.height * (1 - ratio.y) - rect.height * deviation.y) * ((ratio.x - 1) * rect.width) - (point.x - rect.width + rect.width * deviation.x) * (0 - rect.height * (1 - ratio.y))) < 0 and   --判断菱形右下斜边,平行四边形则为右斜边(x2,y2)为右定点
        ((point.y - rect.height * (1 - ratio.y) + rect.height * deviation.y) * (rect.width * (ratio.x)) + (point.x - rect.width + rect.width * deviation.x) * (rect.height * ratio.y)) < 0 and   --判断菱形右上斜边,平行四边形则为上底(x2,y2)为右定点
        ((point.y - rect.height * ratio.y - rect.height * deviation.y ) * (rect.width * (ratio.x)) - (point.x - rect.width * deviation.x) * (0 - rect.height * ratio.y)) > 0 then   --判断菱形左上斜边,平行四边形则为下底(x2,y2)为左定点
        ret = true
    end

    return ret
end

function cc.rectIntersectsRect( rect1, rect2 )
    local intersect = not ( rect1.x > rect2.x + rect2.width or
                    rect1.x + rect1.width < rect2.x         or
                    rect1.y > rect2.y + rect2.height        or
                    rect1.y + rect1.height < rect2.y )

    return intersect
end

cc.Handler = cc.Handler or {}
cc.SCROLLVIEW_SCRIPT_SCROLL = 0
cc.SCROLLVIEW_SCRIPT_ZOOM   = 1
cc.TABLECELL_TOUCHED        = 2
cc.TABLECELL_HIGH_LIGHT     = 3
cc.TABLECELL_UNHIGH_LIGHT   = 4
cc.TABLECELL_WILL_RECYCLE   = 5
cc.TABLECELL_SIZE_FOR_INDEX = 6
cc.TABLECELL_AT_INDEX  = 7
cc.NUMBER_OF_CELLS_IN_TABLEVIEW = 8

cc.SCROLLVIEW_DIRECTION_NONE = -1
cc.SCROLLVIEW_DIRECTION_HORIZONTAL = 0
cc.SCROLLVIEW_DIRECTION_VERTICAL = 1
cc.SCROLLVIEW_DIRECTION_BOTH  = 2

cc.TABLEVIEW_FILL_TOPDOWN = 0
cc.TABLEVIEW_FILL_BOTTOMUP = 1
cc.Handler.EVENT_PHYSICS_CONTACT_BEGIN = 53
cc.Handler.EVENT_PHYSICS_CONTACT_PRESOLVE = 54
cc.Handler.EVENT_PHYSICS_CONTACT_POSTSOLVE = 55
cc.Handler.EVENT_PHYSICS_CONTACT_SEPERATE = 56
