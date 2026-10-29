// GUI_Extension: 底部面板里挂上格挡力量条的悬停区。
// 原版两条的规则是「交互体位置 = 条起点 - 2」，高亮在 Draw 里再 +2 贴回条上。
// 格挡条起点是面板内的 412，所以这里写 410。
scr_guiCreateInteractive(id, o_msl_blockhover, depth - 1, 410, 9 + barsOffsetY);
