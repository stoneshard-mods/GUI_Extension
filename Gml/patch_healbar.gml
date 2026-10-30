// GUI_Extension: 底部面板两条槽位都拆开用
//   左槽（原生命条，158px）：开「神智斗志」时 = 生命容器（面板左端）+ 斗志 50% / 神智 50%
//                            关掉时 = 原版整条生命条
//   右槽（原精力条，167px）：开「格挡条」时 = 格挡力量铺满整槽 + 精力容器（右端对称位置）
//                            关掉时 = 原版精力条
// 注意：这里必须写 argument0/argument1，不能写 arg0/arg1 —— 在 with 块里重新编译时
// argN 会被解析成实例变量(self.argN)，进游戏就是「变量未定义」。

var _msl_barH = _healthBarHeight
var _msl_show_psy = variable_global_exists("msl_gui_ext_show_psy") ? global.msl_gui_ext_show_psy : 1
var _msl_show_bp = variable_global_exists("msl_gui_ext_show_bp") ? global.msl_gui_ext_show_bp : 1

// 液体容器尺寸（生命 / 精力两根同款）：22x46，45 帧长图，底对齐面板底
var _msl_tubeW = 22
var _msl_tubeH = 46
var _msl_tubeY = other.y + other.sprite_height - _msl_tubeH

if (_msl_show_psy)
{
    // ---- 生命容器（面板内 x=138，技能格 1 左边那道缝）----
    var _msl_tubeX = other.x + 138
    var _msl_hp_max = max(_maxHP, 1)
    var _msl_hpFrame = clamp(math_round(_HP / _msl_hp_max * 44), 0, 44)

    // 容器只印当前值（上限那行去掉，观感优先）；上限与扣减放到悬停提示（o_msl_hpinfo）
    draw_sprite_part(s_msl_hptube, 0, _msl_hpFrame * _msl_tubeW, 0, _msl_tubeW, _msl_tubeH, _msl_tubeX, _msl_tubeY)
    scr_drawText(_msl_tubeX + _msl_tubeW / 2, _msl_tubeY + 23, string(_HP), c_white, fa_center, fa_middle, global.f_digits, 0.4)

    // ---- 槽位：斗志 / 神智 各占一半 ----
    var _msl_statGap = 1
    var _msl_mor_W = math_round((_healthBarWidth - _msl_statGap) / 2)
    var _msl_san_W = _healthBarWidth - _msl_statGap - _msl_mor_W
    var _msl_mor_x = argument0
    var _msl_san_x = _msl_mor_x + _msl_mor_W + _msl_statGap

    // 斗志：0-100，低于 50 整条转红
    var _msl_mor_v = clamp(scr_atr("Morale", 100), 0, 100)
    var _msl_mor_fill = clamp(math_round(_msl_mor_W * _msl_mor_v / 100), 0, _msl_mor_W)
    var _msl_mor_spr = (_msl_mor_v < 50) ? s_msl_stat_low : s_msl_morale

    draw_sprite_part(s_holdbar, 0, 0, 0, _msl_mor_W, _msl_barH, _msl_mor_x, argument1)

    if (_msl_mor_fill > 0)
        draw_sprite_part(_msl_mor_spr, 0, 0, 0, _msl_mor_fill, _msl_barH, _msl_mor_x, argument1)

    scr_drawText(_msl_mor_x + _msl_mor_W / 2, argument1 + _msl_barH / 2, string(math_round(_msl_mor_v)), c_white, fa_center, fa_middle, global.f_digits)

    // 神智：0-100，低于 50 整条转红
    var _msl_san_v = clamp(scr_atr("Sanity", 100), 0, 100)
    var _msl_san_fill = clamp(math_round(_msl_san_W * _msl_san_v / 100), 0, _msl_san_W)
    var _msl_san_spr = (_msl_san_v < 50) ? s_msl_stat_low : s_msl_sanity

    draw_sprite_part(s_holdbar, 0, 0, 0, _msl_san_W, _msl_barH, _msl_san_x, argument1)

    if (_msl_san_fill > 0)
        draw_sprite_part(_msl_san_spr, 0, 0, 0, _msl_san_fill, _msl_barH, _msl_san_x, argument1)

    scr_drawText(_msl_san_x + _msl_san_W / 2, argument1 + _msl_barH / 2, string(math_round(_msl_san_v)), c_white, fa_center, fa_middle, global.f_digits)
}
else
{
    // ---- 关掉神智/斗志：完全还原原版生命条（阈值、掉落残影、居中数值）----
    if (_thresholdWidth < _healthBarWidth)
        draw_sprite_part(s_holdbar, 1, 0, 0, (_thresholdWidth + 1), _healthBarHeight, argument0, argument1)

    draw_sprite_part(s_holdbar, 0, 0, 0, _thresholdWidth, _healthBarHeight, argument0, argument1)
    draw_sprite_part(s_healthbar, 0, 0, 0, _healthWidth, _healthBarHeight, argument0, argument1)

    if (_healthBarWidth != _thresholdWidth || (_HP > 0 && _HP < _maxHP))
        draw_sprite_part(s_healthbar, 1, 0, 0, (_healthWidth + 1), _healthBarHeight, argument0, argument1)

    draw_sprite_part(s_healthbar, 0, 0, 0, _healthWidth2, _healthBarHeight, argument0, argument1)
    scr_drawText((argument0 + _healthBarWidth / 2), (argument1 + _healthBarHeight / 2), (string(_HP) + "/" + string(_maxHP)), c_white, fa_center, fa_middle, global.f_digits)
}

// ================= 右槽：格挡力量（铺满整槽）+ 精力容器 =================
if (_msl_show_bp)
{
    var _msl_bp_W = _energyBarWidth
    var _msl_bp_x = argument0 + 163

    // ---- 格挡力量（橙色），数值实时取角色属性：格挡力量/格挡力量上限/格挡几率 ----
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

    // ---- 精力容器（右端对称位置：面板内 x=498）----
    var _msl_mpTubeX = other.x + 498
    var _msl_mp_max = max(_maxMP, 1)
    var _msl_mpFrame = clamp(math_round(_MP / _msl_mp_max * 44), 0, 44)

    // 同样只印当前值，上限与疲劳扣减放到悬停提示（o_msl_mpinfo）
    draw_sprite_part(s_msl_mptube, 0, _msl_mpFrame * _msl_tubeW, 0, _msl_tubeW, _msl_tubeH, _msl_mpTubeX, _msl_tubeY)
    scr_drawText(_msl_mpTubeX + _msl_tubeW / 2, _msl_tubeY + 23, string(_MP), c_white, fa_center, fa_middle, global.f_digits, 0.4)
}
else
{
    // ---- 关掉格挡条：完全还原原版精力条（阈值、掉精力拖影、居中数值）----
    if (_energyThreshold < _energyThresholdWidth)
        draw_sprite_part(s_holdbar_mana, 1, 0, 0, (_energyThresholdWidth + 1), _energyBarHeight, (argument0 + 163), argument1)

    draw_sprite_part(s_holdbar_mana, 0, 0, 0, _energyThresholdWidth, _energyBarHeight, (argument0 + 163), argument1)
    draw_sprite_part(s_hp_n, 0, 0, 0, _energyWidth, _energyBarHeight, (argument0 + 163), argument1)

    if (_energyBarWidth != _energyThreshold || (_MP > 0 && _MP < _maxMP))
        draw_sprite_part(s_hp_n, 1, 0, 0, (_energyWidth + 1), _energyBarHeight, (argument0 + 163), argument1)

    draw_sprite_part(s_hp_n, 0, 0, 0, _energyWidth2, _energyBarHeight, (argument0 + 163), argument1)
    scr_drawText((argument0 + _energyBarWidth / 2 + 163), (argument1 + _energyBarHeight / 2), (string(_MP) + "/" + string(_maxMP)), c_white, fa_center, fa_middle, global.f_digits)
}
