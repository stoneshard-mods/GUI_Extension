// GUI_Extension: 勾选项绘制前先翻译文本（只翻本 mod 那几条，其它原样返回）。
// 插在 o_checkbox_Draw_0 的最前面，因为 text 就在同一个事件里被画出来。
text = scr_msl_gui_ext_tr(text)
