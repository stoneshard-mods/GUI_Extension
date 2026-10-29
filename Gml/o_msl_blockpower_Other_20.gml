// GUI_Extension: 格挡力量条的提示内容（o_hoverCharEnergy 的 User 10 = 更新内容与尺寸）。
// 父对象那份填的是精力数据，所以这里不调用 event_inherited()，只沿用它的排版变量。
// 注意：MODS 里的「显示格挡几率」只管条上的数字，这里始终带上格挡几率。
with (owner)
{
    var _msl_bp = max(Block_Power, 0);
    var _msl_bp_max = max(Block_PowerMax, 0);
    var _msl_bp_percent = (_msl_bp_max > 0) ? math_round((_msl_bp / _msl_bp_max) * 100) : 0;
    var _msl_bp_desc = ds_map_find_value_ext(global.attribute_desc, "Block_Power", "");
    var _msl_prr_line = scr_hoversGetAttributeName("PRR") + scr_actionsLogGetSymbol("colon") + scr_actionsLogGetSpace() + scr_hoversGetAttributeValueString("PRR", PRR + global.magalomania_value, false);

    other.titlePartLeft = scr_hoversGetAttributeName("Block_Power") + scr_actionsLogGetSpace();
    other.titlePartRight = scr_stringNumberFormat(_msl_bp) + "/" + scr_stringNumberFormat(_msl_bp_max);
    other.titleColor = (_msl_bp_percent >= 50) ? 16777215 : make_colour_rgb(158, 27, 49);
    other.description = (_msl_bp_desc == "") ? _msl_prr_line : (_msl_bp_desc + "\n" + _msl_prr_line);
}

titleHeight = scr_stringGetHeight(titlePartLeft + titlePartRight, global.f_digits, textScale);
scr_colorTextCreate(descriptionTextMap, description, make_colour_rgb(157, 154, 154), minWidth, textScale);
descriptionHeight = ds_map_find_value(descriptionTextMap, "height");
contentWidth = minWidth;
contentHeight = titleHeight + lineHeight + descriptionHeight;
