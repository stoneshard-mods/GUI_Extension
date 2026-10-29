// GUI_Extension: 右下角时间显示（天数 + 24 小时制 hh:mm），可在 MODS 设置里关掉。
// 底部面板由 scr_adaptiveMenusPositionUpdate 摆成「水平居中 + 贴底」：
//   x = 屏幕左 + (cameraWidth - sprite_width) / 2 ， y = 屏幕下 - sprite_height
// 所以屏幕右/下边界能直接用面板自己的位置换算，跟分辨率无关。
if (variable_global_exists("msl_gui_ext_show_clock") ? global.msl_gui_ext_show_clock : 1)
{
    var _msl_day = (ds_map_find_value(global.timeDataMap, "months") * 30) + ds_map_find_value(global.timeDataMap, "days") + 1
    var _msl_hour = ds_map_find_value(global.timeDataMap, "hours")
    var _msl_minute = ds_map_find_value(global.timeDataMap, "minutes")
    var _msl_dayWord = ds_list_find_value(global.other_hover, 53)

    if (!is_string(_msl_dayWord))
        _msl_dayWord = ""

    var _msl_hourText = string(_msl_hour)
    var _msl_minuteText = string(_msl_minute)

    if (_msl_hour < 10)
        _msl_hourText = "0" + _msl_hourText

    if (_msl_minute < 10)
        _msl_minuteText = "0" + _msl_minuteText

    var _msl_clock = string(_msl_day) + " " + scr_pluralFormChoose(_msl_day, _msl_dayWord) + "  " + _msl_hourText + ":" + _msl_minuteText
    var _msl_edgeRight = x + (sprite_width + global.cameraWidth) / 2 - 6
    var _msl_edgeBottom = y + sprite_height - 4

    scr_drawText(_msl_edgeRight, _msl_edgeBottom, _msl_clock, c_white, fa_right, fa_bottom, global.f_digits, 0.75)
}
