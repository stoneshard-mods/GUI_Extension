// GUI_Extension: 生命容器 / 斗志 / 神智 / 精力容器 的悬停区。
// 规则和原版一致：交互体位置 = 元件左上 - 2；两根容器是贴底的，y 按面板高度现算。
var _msl_panelW = sprite_get_width(s_healthbar)
var _msl_halfW = math_round((_msl_panelW - 1) / 2)
var _msl_panelMorX = 164
var _msl_panelSanX = 164 + _msl_halfW + 1
var _msl_tubeHoverY = sprite_height - 46 - 2
scr_guiCreateInteractive(id, o_msl_hptubehover, depth - 1, 136, _msl_tubeHoverY)
scr_guiCreateInteractive(id, o_msl_moralehover, depth - 1, _msl_panelMorX - 2, 9 + barsOffsetY)
scr_guiCreateInteractive(id, o_msl_sanityhover, depth - 1, _msl_panelSanX - 2, 9 + barsOffsetY)
scr_guiCreateInteractive(id, o_msl_mptubehover, depth - 1, 496, _msl_tubeHoverY)
