// GUI_Extension: 给斗志 / 神智各挂一个悬停区。
// 原版规则：交互体位置 = 条起点 - 2（高亮在 Draw 里 +2 贴回条上）。
// 位置按 scr_healbar 里那套 60/20/20 的算法推，改比例时两处要一起改。
var _msl_panelHpW = math_round(sprite_get_width(s_healthbar) * 0.6)
var _msl_panelMorW = math_round(sprite_get_width(s_healthbar) * 0.2)
var _msl_panelMorX = 164 + _msl_panelHpW + 1
var _msl_panelSanX = _msl_panelMorX + _msl_panelMorW + 1
scr_guiCreateInteractive(id, o_msl_moralehover, depth - 1, _msl_panelMorX - 2, 9 + barsOffsetY)
scr_guiCreateInteractive(id, o_msl_sanityhover, depth - 1, _msl_panelSanX - 2, 9 + barsOffsetY)
