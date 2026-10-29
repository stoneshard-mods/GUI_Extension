// GUI_Extension: 生命容器的悬停内容（父对象 o_hoverCharHealth，覆盖 User 10）。
// 条上不再印数字，所以这里承担全部数值：
//   标题右侧 = 当前/有效上限（上限已按 Health_Threshold 扣过伤势）
//   正文首行 = 有效上限 / 原始上限（-扣减%），只在确实被伤势压过时出现
// 不调用 event_inherited()，父对象那份填的是原版百分比标题。
with (owner)
{
    var _msl_hpCur = scr_hoversGetAttributeValue("HP", HP + global.magalomania_value);
    var _msl_thr = math_round(Health_Threshold);
    var _msl_thrLoss = math_round(100 - _msl_thr);
    var _msl_maxEff = max(1, math_round(((max_hp * _msl_thr) / 100) + global.magalomania_value));
    var _msl_maxRaw = max(1, math_round(max_hp + global.magalomania_value));
    var _msl_percent = math_round((_msl_hpCur / _msl_maxEff) * 100);
    var _msl_restoration = math_round(Health_Restoration + global.magalomania_value);
    var _msl_turns = (_msl_restoration == 0) ? 0 : max(0, math_round(100 / _msl_restoration));

    other.titlePartLeft = scr_colorTextGetHeader("health") + scr_actionsLogGetSpace();
    other.titlePartRight = string(_msl_hpCur) + "/" + string(_msl_maxEff);
    other.titleColor = (_msl_percent >= 50) ? 16777215 : make_colour_rgb(158, 27, 49);

    other.description = scr_colorTextGetHover("health");

    if (_msl_thrLoss > 0)
        other.description += scr_colorTextGetHover("healthThreshold");

    other.description = scr_colorTextStringPlaceholdersReplace(other.description, [_msl_turns, _msl_thrLoss]);

    if (_msl_thrLoss > 0)
        other.description = string(_msl_maxEff) + " / " + string(_msl_maxRaw) + " (-" + string(_msl_thrLoss) + "%)" + "\n" + other.description;
}

titleHeight = scr_stringGetHeight(titlePartLeft + titlePartRight, global.f_digits, textScale);
scr_colorTextCreate(descriptionTextMap, description, make_colour_rgb(157, 154, 154), minWidth, textScale);
descriptionHeight = ds_map_find_value(descriptionTextMap, "height");
contentWidth = minWidth;
contentHeight = titleHeight + lineHeight + descriptionHeight;
