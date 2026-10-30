// GUI_Extension: 敌人头顶的 6px 血条（A 方案：挂在 o_enemy 的 Draw End 末尾）。
// 默认只在该敌人被鼠标悬浮时出现；MODS 勾了「敌人血条常显」后改为始终显示。
// 过滤：训练假人（is_dummy_ancestor）、不可见、已死亡、UI 关闭。
// 外观：1px 黑边 + 4px 纵向渐变填充（合计 6px），按血量比例三档配色。
var _msl_always = 0

if (variable_global_exists("msl_gui_ext_enemyhp_always"))
    _msl_always = global.msl_gui_ext_enemyhp_always

if (global.UI_is_on && !is_dummy_ancestor && visible && HP > 0)
{
    // 悬浮判定和原版交互一致：命中自己、非施法瞄准、非过场、鼠标不在 GUI 上
    var _msl_hover = position_meeting(mouse_x, mouse_y, id) && !global.skill_activate && !scr_is_cutscene() && !position_meeting(global.guiMouseX, global.guiMouseY, c_GUI)
    var _msl_show = (_msl_always == 1) || _msl_hover

    if (_msl_show)
    {
        var _msl_p = clamp(HP / max(1, max_hp), 0, 1)
        var _msl_w = 26

        // 三档配色：>60% 绿 / 30%~60% 黄 / <30% 红（每档给亮/中/暗三色做渐变）
        var _msl_hi = make_colour_rgb(168, 244, 186)
        var _msl_mid = make_colour_rgb(114, 222, 142)
        var _msl_lo = make_colour_rgb(52, 138, 84)

        if (_msl_p < 0.3)
        {
            _msl_hi = make_colour_rgb(255, 116, 108)
            _msl_mid = make_colour_rgb(226, 42, 52)
            _msl_lo = make_colour_rgb(120, 10, 20)
        }
        else if (_msl_p < 0.6)
        {
            _msl_hi = make_colour_rgb(255, 232, 150)
            _msl_mid = make_colour_rgb(240, 198, 92)
            _msl_lo = make_colour_rgb(150, 108, 34)
        }

        var _msl_bx = round(x - _msl_w / 2)
        var _msl_by = bbox_top - 14
        var _msl_fill = clamp(math_round(_msl_w * _msl_p), 0, _msl_w)

        // 1px 黑边（外圈），里面是暗槽
        draw_set_color(c_black)
        draw_rectangle(_msl_bx - 1, _msl_by - 1, _msl_bx + _msl_w, _msl_by + 4, false)
        draw_set_color(make_colour_rgb(32, 12, 16))
        draw_rectangle(_msl_bx, _msl_by, _msl_bx + _msl_w - 1, _msl_by + 3, false)

        // 血量：4 行纵向渐变（亮 → 中 → 中 → 暗）
        if (_msl_fill > 0)
        {
            draw_set_color(_msl_hi)
            draw_rectangle(_msl_bx, _msl_by, _msl_bx + _msl_fill - 1, _msl_by, false)

            draw_set_color(_msl_mid)
            draw_rectangle(_msl_bx, _msl_by + 1, _msl_bx + _msl_fill - 1, _msl_by + 2, false)

            draw_set_color(_msl_lo)
            draw_rectangle(_msl_bx, _msl_by + 3, _msl_bx + _msl_fill - 1, _msl_by + 3, false)
        }

        draw_set_color(c_white)
    }
}
