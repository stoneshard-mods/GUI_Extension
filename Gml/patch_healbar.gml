// GUI_Extension: 底部面板两条槽位重新分配
//   左槽（原生命条，158px）：生命横条 —— 就是原版整条样式（阈值残段 + 掉血残影 + 当前/上限）
//   右槽（原精力条，167px）：开「格挡条」时 = 精力 50% + 格挡力量 50%
//                            关掉时        = 原版整条精力条
//   斗志 / 神智：两根柱状液体容器，立在面板两端（面板内 x=138 / x=498），贴底
// 注意：这里必须写 argument0/argument1，不能写 arg0/arg1 —— 在 with 块里重新编译时
// argN 会被解析成实例变量(self.argN)，进游戏就是「变量未定义」。

var _msl_barH = _healthBarHeight
var _msl_show_psy = variable_global_exists("msl_gui_ext_show_psy") ? global.msl_gui_ext_show_psy : 1
var _msl_show_bp = variable_global_exists("msl_gui_ext_show_bp") ? global.msl_gui_ext_show_bp : 1

// 柱状容器尺寸（斗志 / 神智 两根同款）：22x46，45 帧长图，底对齐面板底
var _msl_tubeW = 22
var _msl_tubeH = 46
var _msl_tubeY = other.y + other.sprite_height - _msl_tubeH

// ================= 左槽：生命横条（原版整条样式）=================
if (_thresholdWidth < _healthBarWidth)
    draw_sprite_part(s_holdbar, 1, 0, 0, (_thresholdWidth + 1), _healthBarHeight, argument0, argument1)

draw_sprite_part(s_holdbar, 0, 0, 0, _thresholdWidth, _healthBarHeight, argument0, argument1)
draw_sprite_part(s_healthbar, 0, 0, 0, _healthWidth, _healthBarHeight, argument0, argument1)

if (_healthBarWidth != _thresholdWidth || (_HP > 0 && _HP < _maxHP))
    draw_sprite_part(s_healthbar, 1, 0, 0, (_healthWidth + 1), _healthBarHeight, argument0, argument1)

draw_sprite_part(s_healthbar, 0, 0, 0, _healthWidth2, _healthBarHeight, argument0, argument1)
scr_drawText((argument0 + _healthBarWidth / 2), (argument1 + _healthBarHeight / 2), (string(_HP) + "/" + string(_maxHP)), c_white, fa_center, fa_middle, global.f_digits)

// ================= 斗志 / 神智：两根柱状容器（面板两端）=================
if (_msl_show_psy)
{
    // 斗志：0-100，低于 50 换红色容器（复用生命那根管子的配色）
    var _msl_mor_v = clamp(scr_atr("Morale", 100), 0, 100)
    var _msl_mor_spr = (_msl_mor_v < 50) ? s_msl_hptube : s_msl_moraltube
    var _msl_mor_frame = clamp(math_round(_msl_mor_v / 100 * 44), 0, 44)
    var _msl_mor_x = other.x + 138

    draw_sprite_part(_msl_mor_spr, 0, _msl_mor_frame * _msl_tubeW, 0, _msl_tubeW, _msl_tubeH, _msl_mor_x, _msl_tubeY)
    scr_drawText(_msl_mor_x + _msl_tubeW / 2, _msl_tubeY + 23, string(math_round(_msl_mor_v)), c_white, fa_center, fa_middle, global.f_digits, 0.4)

    // 神智：同款，右端对称位置
    var _msl_san_v = clamp(scr_atr("Sanity", 100), 0, 100)
    var _msl_san_spr = (_msl_san_v < 50) ? s_msl_hptube : s_msl_sanitytube
    var _msl_san_frame = clamp(math_round(_msl_san_v / 100 * 44), 0, 44)
    var _msl_san_x = other.x + 498

    draw_sprite_part(_msl_san_spr, 0, _msl_san_frame * _msl_tubeW, 0, _msl_tubeW, _msl_tubeH, _msl_san_x, _msl_tubeY)
    scr_drawText(_msl_san_x + _msl_tubeW / 2, _msl_tubeY + 23, string(math_round(_msl_san_v)), c_white, fa_center, fa_middle, global.f_digits, 0.4)
}

// ================= 右槽：精力 50% + 格挡力量 50% =================
if (_msl_show_bp)
{
    var _msl_gap = 1
    var _msl_mp_W = math_round((_energyBarWidth - _msl_gap) / 2)
    var _msl_bp_W = _energyBarWidth - _msl_gap - _msl_mp_W
    var _msl_mp_x = argument0 + 163
    var _msl_bp_x = _msl_mp_x + _msl_mp_W + _msl_gap

    // ---- 精力横条（右槽左半）：轨道 + 掉值残影 + 当前值 ----
    var _msl_mp_max = max(_maxMP, 1)
    var _msl_mp_cur = clamp(math_round(_msl_mp_W * _MP / _msl_mp_max), 0, _msl_mp_W)
    var _msl_mp_sec = clamp(math_round(_msl_mp_W * sec_mp / _msl_mp_max) + 1, 0, _msl_mp_W)

    draw_sprite_part(s_holdbar_mana, 0, 0, 0, _msl_mp_W, _msl_barH, _msl_mp_x, argument1)

    if (_msl_mp_sec > 0)
        draw_sprite_part(s_hp_n, 1, 0, 0, _msl_mp_sec, _msl_barH, _msl_mp_x, argument1)

    if (_msl_mp_cur > 0)
        draw_sprite_part(s_hp_n, 0, 0, 0, _msl_mp_cur, _msl_barH, _msl_mp_x, argument1)

    scr_drawText(_msl_mp_x + _msl_mp_W / 2, argument1 + _msl_barH / 2, (string(_MP) + "/" + string(_maxMP)), c_white, fa_center, fa_middle, global.f_digits)

    // ---- 格挡力量（右槽右半），数值实时取角色属性：格挡力量/格挡力量上限/格挡几率 ----
    var _msl_bp_cur = max(Block_Power, 0)
    var _msl_bp_max = max(Block_PowerMax, 0)
    var _msl_bp_fill = 0
    var _msl_bp_fill_sec = 0

    // 掉值残影：和 sec_hp / sec_mp 同一套 lerp 表现，中间值放在 player 上。
    if (!variable_instance_exists(id, "msl_bp_sec"))
        msl_bp_sec = _msl_bp_cur

    if (msl_bp_sec < _msl_bp_cur)
        msl_bp_sec = _msl_bp_cur
    else if (msl_bp_sec > _msl_bp_cur)
        msl_bp_sec = lerp(msl_bp_sec, _msl_bp_cur, 0.2)

    if (_msl_bp_max > 0)
    {
        _msl_bp_fill = clamp(math_round(_msl_bp_W * _msl_bp_cur / _msl_bp_max), 0, _msl_bp_W)
        _msl_bp_fill_sec = clamp(math_round(_msl_bp_W * msl_bp_sec / _msl_bp_max) + 1, 0, _msl_bp_W)
    }

    draw_sprite_part(s_holdbar_mana, 0, 0, 0, _msl_bp_W, _msl_barH, _msl_bp_x, argument1)

    // 先铺亮色残影（frame 1），再用正常填充（frame 0）盖住，露出来的那截就是刚掉掉的部分。
    if (_msl_bp_fill_sec > 0)
        draw_sprite_part(s_msl_blockbar, 1, 0, 0, _msl_bp_fill_sec, _msl_barH, _msl_bp_x, argument1)

    if (_msl_bp_fill > 0)
        draw_sprite_part(s_msl_blockbar, 0, 0, 0, _msl_bp_fill, _msl_barH, _msl_bp_x, argument1)

    // 格挡几率只是数值，不参与进度条长度；MODS 设置里可以关掉「格挡条显示几率」（global.msl_gui_ext_prr_on_bar）。
    // 这个开关只管条上的数字，悬停详情里的格挡几率始终显示。
    var _msl_bp_text = scr_stringNumberFormat(_msl_bp_cur) + "/" + scr_stringNumberFormat(_msl_bp_max)
    var _msl_show_prr = variable_global_exists("msl_gui_ext_prr_on_bar") ? global.msl_gui_ext_prr_on_bar : 0

    if (_msl_show_prr)
        _msl_bp_text = _msl_bp_text + "/" + scr_stringNumberFormat(PRR) + "%"

    scr_drawText(_msl_bp_x + _msl_bp_W / 2, argument1 + _msl_barH / 2, _msl_bp_text, c_white, fa_center, fa_middle, global.f_digits)
}
else
{
    // ---- 关掉格挡条：完全还原原版精力条（阈值、拖影、居中数值）----
    if (_energyThreshold < _energyThresholdWidth)
        draw_sprite_part(s_holdbar_mana, 1, 0, 0, (_energyThresholdWidth + 1), _energyBarHeight, (argument0 + 163), argument1)

    draw_sprite_part(s_holdbar_mana, 0, 0, 0, _energyThresholdWidth, _energyBarHeight, (argument0 + 163), argument1)
    draw_sprite_part(s_hp_n, 0, 0, 0, _energyWidth, _energyBarHeight, (argument0 + 163), argument1)

    if (_energyBarWidth != _energyThreshold || (_MP > 0 && _MP < _maxMP))
        draw_sprite_part(s_hp_n, 1, 0, 0, (_energyWidth + 1), _energyBarHeight, (argument0 + 163), argument1)

    draw_sprite_part(s_hp_n, 0, 0, 0, _energyWidth2, _energyBarHeight, (argument0 + 163), argument1)
    scr_drawText((argument0 + _energyBarWidth / 2 + 163), (argument1 + _energyBarHeight / 2), (string(_MP) + "/" + string(_maxMP)), c_white, fa_center, fa_middle, global.f_digits)
}
