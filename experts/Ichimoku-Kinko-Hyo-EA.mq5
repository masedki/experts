/**
 * @copyright   2019, pipbolt.io
 * @license     https://github.com/pipbolt/experts/blob/master/LICENSE
 */

#property copyright "Copyright 2019, pipbolt.io"
#property link "https://pipbolt.io"
#property icon "/include/PipboltFramework/favicon.ico"
#property description "Visit pipbolt.io for more EAs for Metatrader 5."
#property version "0.007"

//--- Include the main functions
#include <PipboltFramework\Params\MainSettings.mqh>

//--- Entry Strategy
input string Entry_Strategy = "----------"; // ---------- Entry Strategy ----------

//--- Exit Strategy
input string Exit_Strategy = "----------"; // ---------- Exit Strategy ----------
input bool UseExitStrategy = false;        // Use Exit Strategy

//--- Indicator Settings
input string Stochastic_Oscillator = "----------"; // ---------- Ichimoku Kynko Hyo ----------
input int tenkanSen = 9;                           // period of Tenkan-sen
input int kijunSen = 26;                           // period of Kijun-sen
input int senkouSpanB = 52;                        // period of Senkou Span B

#include <PipboltFramework\Params\BreakEven.mqh>
#include <PipboltFramework\Params\TrailingStop.mqh>
#include <PipboltFramework\Params\TimeFilter.mqh>

//-- Indicators
CiIchimoku Ichimoku;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit(void)
{
    // Checks
    if (!cLicense.CheckLicense() || !Main.OnInitChecks())
        return (INIT_FAILED);

    // Init Main Functions
    InitMainSettings();

    // Init TrailingStop
    InitTrailingStop(MagicNumber);

    // Init BreakEven
    InitBreakEven(MagicNumber);

    // Init Timer Filter
    InitTimerFilter(MagicNumber);

    // Indicators
    Ichimoku.Init(NULL, NULL, tenkanSen, kijunSen, senkouSpanB);

    //--- ok
    return (INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick(void)
{
    // Checks and Updates
    if (!Main.OnTickChecksAndUpdates())
        return;

    //Execute only if a open position exists
    if (Main.PositionExists())
    {
        cTrailingStop.Trail();
        cBreakEven.Trail();
        cTimeFilter.ExitOnTimer();

        if (UseExitStrategy && Main.IsNewBar())
            CheckForClose();
    }

    // Execute only on a new bar
    if (Main.NewPositionAllowed() && cTimeFilter.TimeFilter() && Main.IsNewBar())
        CheckForOpen();
}
//+------------------------------------------------------------------+
//| Check for open position conditions                               |
//+------------------------------------------------------------------+
void CheckForOpen(void)
{
    // Buy Entry Strategy
    bool openBuy = (Ichimoku.TenkanSen(0) > Ichimoku.KijunSen(0) && Ichimoku.TenkanSen(1) <= Ichimoku.KijunSen(1));

    // Sell Entry Stategy
    bool openSell = (Ichimoku.TenkanSen(0) < Ichimoku.KijunSen(0) && Ichimoku.TenkanSen(1) >= Ichimoku.KijunSen(1));

    // Open Positions
    Main.OpenByEntryStrategy(openBuy, openSell);
}
//+------------------------------------------------------------------+
//| Check for close position conditions                              |
//+------------------------------------------------------------------+
void CheckForClose(void)
{
    // Buy Exit Strategy
    bool closeBuy = (Ichimoku.TenkanSen(0) <= Ichimoku.KijunSen(0));

    // Sell Exit Stategy
    bool closeSell = (Ichimoku.TenkanSen(0) >= Ichimoku.KijunSen(0));

    // Close Positions
    Main.CloseByExitStrategy(closeBuy, closeSell);
}
//+------------------------------------------------------------------+
