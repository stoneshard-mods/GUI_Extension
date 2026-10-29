// GUI_Extension: 格挡力量条的悬停交互体。
// 继承 o_gui_barHover 拿到 hoverID/状态注册，再换成格挡条自己的命中精灵、高亮精灵和提示内容。
event_inherited();
spriteHover = s_msl_blockhover;
hoverObject = o_msl_blockpower;
