// GUI_Extension: 斗志条的悬停说明（o_hoverCharEnergy 的 User 10 = 更新内容与尺寸）。
// 标题 = 名称 + 当前百分比；正文 = 属性说明（把面板用的来源占位符换成真实数值）。
// 父对象那份填的是精力数据，所以这里不调用 event_inherited()。
with (owner)
{
    var _msl_mor = clamp(scr_atr("Morale", 100), 0, 100)
    var _msl_mor_desc = ds_map_find_value_ext(global.attribute_desc, "Morale", "")

    other.titlePartLeft = scr_hoversGetAttributeName("Morale") + scr_actionsLogGetSpace()
    other.titlePartRight = scr_hoversGetAttributeValueString("Morale", _msl_mor, false)
    other.titleColor = (_msl_mor < 50) ? make_colour_rgb(158, 27, 49) : 16777215

    other.description = string_replace_all(_msl_mor_desc, "/*MoraleSituational*/", string(scr_psy_get("MoraleSituational", true)))
    other.description = string_replace_all(other.description, "/*MoraleDiet*/", string(scr_psy_get("MoraleDiet", true)))
    other.description = string_replace_all(other.description, "/*MoraleRest*/", string(scr_psy_get("MoraleRest", true)))
}

titleHeight = scr_stringGetHeight(titlePartLeft + titlePartRight, global.f_digits, textScale)
scr_colorTextCreate(descriptionTextMap, description, make_colour_rgb(157, 154, 154), minWidth, textScale)
descriptionHeight = ds_map_find_value(descriptionTextMap, "height")
contentWidth = minWidth
contentHeight = titleHeight + lineHeight + descriptionHeight
