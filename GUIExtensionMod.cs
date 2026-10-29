using ModShardLauncher;
using ModShardLauncher.Mods;
using UndertaleModLib.Models;

namespace GUI_Extension;

public class GUIExtensionMod : Mod
{
    public override string Name => "GUI_Extension";
    public override string Author => "Pixel32E";
    public override string Description => "GUI 拓展：生命槽拆成 生命/斗志/神智，精力槽拆成 精力/格挡力量，右下角显示天数与时间，各条都有悬停说明";
    public override string ShortDesc => "Split HP/Morale/Sanity and Energy/Block bars, plus a day+clock readout";
    public override string Version => "v1.9.1.0";

    // scr_healbar 里两段绘制代码（生命块 + 精力块）的起止锚点。
    // 游戏改代码时这里抛异常，而不是静默画出错位的东西。
    private const string HealbarCode = "gml_GlobalScript_scr_healbar";
    private const string HealbarStart = "if (_thresholdWidth < _healthBarWidth)";
    private const string HealbarEnd = "string(_MP) + \"/\" + string(_maxMP)";

    private const string BottomPanelCode = "gml_Object_o_bottompanel_Create_0";
    private const string BottomPanelDrawCode = "gml_Object_o_bottompanel_Draw_0";
    private const string EnergyHoverCode = "gml_Object_o_gui_energybarHover_Create_0";
    private const string EnergyHoverObject = "o_gui_energybarHover";
    private const string HealthHoverCode = "gml_Object_o_gui_healthbarHover_Create_0";
    private const string HealthHoverObject = "o_gui_healthbarHover";

    // 反编译器有时把资源写成对象名、有时写成数字 id，两种都认。
    private static readonly string[] EnergyHoverAnchors =
    {
        "scr_guiCreateInteractive(id, o_gui_energybarHover,",
        "scr_guiCreateInteractive(id, 4738,",
    };

    private static readonly string[] HealthHoverAnchors =
    {
        "scr_guiCreateInteractive(id, o_gui_healthbarHover,",
        "scr_guiCreateInteractive(id, 4737,",
    };

    public override void PatchMod()
    {
        ReplaceBars();
        AddBlockBarHover();
        AddStatHovers();
        AddClock();
        AddSettingsMenu();
    }

    private void AddClock()
    {
        // 右下角时间：追加在底部面板的 Draw 末尾（HUD 隐藏时一起消失）。
        InsertAtEnd(BottomPanelDrawCode, Code("patch_bottompanel_clock.gml"), "右下角时间显示");
    }

    private void AddSettingsMenu()
    {
        // 启动器把它渲染成「MODS」页里的一个勾选项：状态存进 msl_menu_mod.ini 的 [GUI_Extension] 段，
        // 开局由 o_msl_initializer 读回 global.msl_gui_ext_prr_on_bar。
        Msl.AddMenu(
            "GUI_Extension",
            new UIComponent(
                "格挡条显示几率 / Show chance on bar",
                "msl_gui_ext_prr_on_bar",
                UIComponentType.CheckBox,
                0),
            new UIComponent(
                "显示神智斗志 / Show sanity & morale",
                "msl_gui_ext_show_psy",
                UIComponentType.CheckBox,
                1),
            new UIComponent(
                "显示格挡条 / Show block power bar",
                "msl_gui_ext_show_bp",
                UIComponentType.CheckBox,
                1),
            new UIComponent(
                "显示时间 / Show clock",
                "msl_gui_ext_show_clock",
                UIComponentType.CheckBox,
                1));
    }

    private void ReplaceBars()
    {
        // 只替换两条槽位的绘制代码：sec_hp / sec_mp 的 lerp、阈值计算都保持原版。
        try
        {
            Msl.LoadGML(HealbarCode)
                .MatchFromUntil(HealbarStart, HealbarEnd)
                .ReplaceBy(ModFiles.GetCode("patch_healbar.gml"))
                .Save();
        }
        catch (System.Exception ex)
        {
            throw new System.InvalidOperationException(
                "GUI_Extension 打补丁失败：替换底部条绘制代码（" + HealbarCode + "）。游戏代码可能已更新。", ex);
        }
    }

    private void AddBlockBarHover()
    {
        // 提示内容：复用 o_hoverCharEnergy 的排版/绘制，只换掉数据来源（User 10 事件）。
        Msl.AddObject("o_msl_blockpower", spriteName: "", parentName: "o_hoverCharEnergy",
            isVisible: true, isPersistent: false, isAwake: true);
        Msl.AddNewEvent("o_msl_blockpower", Code("o_msl_blockpower_Other_20.gml"), EventType.Other, 20);

        // 交互体：复用 o_gui_barHover 的悬停逻辑，命中区/高亮换成右半条那一套。
        Msl.AddObject("o_msl_blockhover", spriteName: "s_msl_blockmask", parentName: "o_gui_barHover",
            isVisible: true, isPersistent: true, isAwake: true);
        Msl.AddNewEvent("o_msl_blockhover", Code("o_msl_blockhover_Create.gml"), EventType.Create, 0);

        // 开关关掉时格挡条的悬停区要退出交互列表（精力条已经恢复整条宽度）。
        Msl.AddNewEvent("o_msl_blockhover", Code("o_msl_bphover_Step.gml"), EventType.Step, 0);

        // 原精力条悬停区是整个槽位，会把右半的格挡条一起盖住
        // （scr_guiControllerInteractiveUpdate 的 instance_position_list 取第一个命中），
        // 所以把它的命中区和高亮也缩到左半；关掉格挡条时再由 Step 换回原版整套。
        InsertAtEnd(EnergyHoverCode, Code("patch_energybar_hover.gml"), "收缩精力条悬停区");
        Msl.AddNewEvent(EnergyHoverObject, Code("patch_energybar_hover.gml"), EventType.Step, 0);

        // 在底部面板里挂上格挡条的悬停区（x = 条起点 - 2，和原版两个条一致）。
        InsertBelow(BottomPanelCode, EnergyHoverAnchors, Code("patch_bottompanel_hover.gml"), "创建格挡条悬停区");
    }

    private void AddStatHovers()
    {
        // 生命悬停的命中区/高亮：Create 里先摆对一次，Step 里跟着设置实时切换。
        InsertAtEnd(HealthHoverCode, Code("patch_healthbar_hover.gml"), "收缩生命条悬停区");
        Msl.AddNewEvent(HealthHoverObject, Code("patch_healthbar_hover.gml"), EventType.Step, 0);

        AddStatHover("o_msl_moraleinfo", "o_msl_moraleinfo_Other_20.gml",
            "o_msl_moralehover", "s_msl_morale_mask", "s_msl_morale_hover");
        AddStatHover("o_msl_sanityinfo", "o_msl_sanityinfo_Other_20.gml",
            "o_msl_sanityhover", "s_msl_sanity_mask", "s_msl_sanity_hover");

        // 在底部面板里挂上两条的悬停区（x = 条起点 - 2）。
        InsertBelow(BottomPanelCode, HealthHoverAnchors, Code("patch_bottompanel_stat_hover.gml"), "创建斗志/神智悬停区");
    }

    private void AddStatHover(string infoName, string infoGml, string hoverName, string maskSprite, string highlightSprite)
    {
        // 提示内容：复用 o_hoverCharEnergy 的排版/绘制，只换掉数据来源（User 10 事件）。
        Msl.AddObject(infoName, spriteName: "", parentName: "o_hoverCharEnergy",
            isVisible: true, isPersistent: false, isAwake: true);
        Msl.AddNewEvent(infoName, Code(infoGml), EventType.Other, 20);

        // 交互体：复用 o_gui_barHover 的悬停逻辑，命中区/高亮用自己那一套。
        Msl.AddObject(hoverName, spriteName: maskSprite, parentName: "o_gui_barHover",
            isVisible: true, isPersistent: true, isAwake: true);
        Msl.AddNewEvent(hoverName,
            "event_inherited()\nspriteHover = " + highlightSprite + "\nhoverObject = " + infoName + "\n",
            EventType.Create, 0);

        // 开关关掉时这两个悬停区要退出交互列表（生命条已经恢复整条宽度）。
        Msl.AddNewEvent(hoverName, Code("o_msl_stathover_Step.gml"), EventType.Step, 0);
    }

    private string Code(string fileName)
    {
        return ModFiles.GetCode(fileName);
    }

    private static void InsertBelow(string codeName, string[] anchors, string code, string what)
    {
        System.Exception last = null;

        foreach (string anchor in anchors)
        {
            try
            {
                Msl.LoadGML(codeName).MatchFrom(anchor).InsertBelow(code).Save();
                return;
            }
            catch (System.Exception ex)
            {
                last = ex;
            }
        }

        throw new System.InvalidOperationException(
            "GUI_Extension 打补丁失败：" + what + "（" + codeName + "）。游戏代码可能已更新。", last);
    }

    private static void InsertAtEnd(string codeName, string code, string what)
    {
        try
        {
            Msl.LoadGML(codeName).MatchAll().InsertBelow(code).Save();
        }
        catch (System.Exception ex)
        {
            throw new System.InvalidOperationException(
                "GUI_Extension 打补丁失败：" + what + "（" + codeName + "）。游戏代码可能已更新。", ex);
        }
    }
}
