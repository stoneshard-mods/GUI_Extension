// GUI_Extension: 格挡条现在铺满整个右槽（面板内 x=327..493），
// 交互体位置 = 条起点 - 2（高亮在 Draw 里 +2 贴回条上）。
scr_guiCreateInteractive(id, o_msl_blockhover, depth - 1, 325, 9 + barsOffsetY)
