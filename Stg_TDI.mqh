/**
 * @file
 * Implements TDI strategy based on the TDI indicator.
 */

// Includes.
#include "Indi_TDI.mqh"

// User input params.
INPUT_GROUP("TDI strategy: strategy params");
INPUT float TDI_LotSize = 0;                // Lot size
INPUT int TDI_SignalOpenMethod = 0;         // Signal open method
INPUT float TDI_SignalOpenLevel = 0;        // Signal open level
INPUT int TDI_SignalOpenFilterMethod = 32;  // Signal open filter method
INPUT int TDI_SignalOpenFilterTime = 3;     // Signal open filter time (0-31)
INPUT int TDI_SignalOpenBoostMethod = 0;    // Signal open boost method
INPUT int TDI_SignalCloseMethod = 0;        // Signal close method
INPUT int TDI_SignalCloseFilter = 32;       // Signal close filter (-127-127)
INPUT float TDI_SignalCloseLevel = 0;       // Signal close level
INPUT int TDI_PriceStopMethod = 0;          // Price limit method
INPUT float TDI_PriceStopLevel = 2;         // Price limit level
INPUT int TDI_TickFilterMethod = 32;        // Tick filter method (0-255)
INPUT float TDI_MaxSpread = 4.0;            // Max spread to trade (in pips)
INPUT short TDI_Shift = 0;                  // Shift
INPUT float TDI_OrderCloseLoss = 80;        // Order close loss
INPUT float TDI_OrderCloseProfit = 80;      // Order close profit
INPUT int TDI_OrderCloseTime = -30;         // Order close time in mins (>0) or bars (<0)
INPUT_GROUP("TDI strategy: TDI indicator params");
INPUT ENUM_IDATA_SOURCE_TYPE TDI_Indi_TDI_SourceType = IDATA_INDICATOR;  // Source type
INPUT int TDI_Indi_TDI_RSI_Period = 13;         // RSI Period (8-25)
INPUT int TDI_Indi_TDI_RSI_Price = 0;           // RSI Price (0-6)
INPUT int TDI_Indi_TDI_Volatility_Band = 34;    // Volatility Band (20-40)
INPUT int TDI_Indi_TDI_RSI_Price_Line = 2;      // RSI Price Line
INPUT int TDI_Indi_TDI_RSI_Price_Type = 0;      // RSI Price Type (0-3)
INPUT int TDI_Indi_TDI_Trade_Signal_Line = 7;   // Trade Signal Line
INPUT int TDI_Indi_TDI_Trade_Signal_Type = 0;   // Trade Signal Type (0-3)
INPUT int TDI_Indi_TDI_Shift = 0;  // Shift

// Structs.

// Defines struct with default user strategy values.
struct Stg_TDI_Params_Defaults : StgParams {
  Stg_TDI_Params_Defaults()
      : StgParams(::TDI_SignalOpenMethod, ::TDI_SignalOpenFilterMethod, ::TDI_SignalOpenLevel,
                  ::TDI_SignalOpenBoostMethod, ::TDI_SignalCloseMethod, ::TDI_SignalCloseFilter, ::TDI_SignalCloseLevel,
                  ::TDI_PriceStopMethod, ::TDI_PriceStopLevel, ::TDI_TickFilterMethod, ::TDI_MaxSpread, ::TDI_Shift) {
    Set(STRAT_PARAM_LS, TDI_LotSize);
    Set(STRAT_PARAM_OCL, TDI_OrderCloseLoss);
    Set(STRAT_PARAM_OCP, TDI_OrderCloseProfit);
    Set(STRAT_PARAM_OCT, TDI_OrderCloseTime);
    Set(STRAT_PARAM_SOFT, TDI_SignalOpenFilterTime);
  }
};

#ifdef __config__
// Loads pair specific param values.
#include "config/H1.h"
#include "config/H4.h"
#include "config/H8.h"
#include "config/M1.h"
#include "config/M15.h"
#include "config/M30.h"
#include "config/M5.h"
#endif

class Stg_TDI : public Strategy {
 public:
  Stg_TDI(StgParams &_sparams, TradeParams &_tparams, ChartParams &_cparams, string _name = "")
      : Strategy(_sparams, _tparams, _cparams, _name) {}

  static Stg_TDI *Init(ENUM_TIMEFRAMES _tf = NULL, EA *_ea = NULL) {
    // Initialize strategy initial values.
    Stg_TDI_Params_Defaults stg_tdi_defaults;
    StgParams _stg_params(stg_tdi_defaults);
#ifdef __config__
    SetParamsByTf<StgParams>(_stg_params, _tf, stg_tdi_m1, stg_tdi_m5, stg_tdi_m15, stg_tdi_m30, stg_tdi_h1, stg_tdi_h4,
                             stg_tdi_h8);
#endif
    // Initialize indicator.
    // Initialize Strategy instance.
    ChartParams _cparams(_tf, _Symbol);
    TradeParams _tparams;
    Strategy *_strat = new Stg_TDI(_stg_params, _tparams, _cparams, "TDI");
    return _strat;
  }

  /**
   * Event on strategy's init.
   */
  void OnInit() {
    IndiTDIParams _indi_params(::TDI_Indi_TDI_Shift);
    _indi_params.SetTf(Get<ENUM_TIMEFRAMES>(STRAT_PARAM_TF));
    SetIndicator(new Indi_TDI(_indi_params));
  }

  /**
   * Check strategy's opening signal.
   */
  bool SignalOpen(ENUM_ORDER_TYPE _cmd, int _method, float _level = 0.0f, int _shift = 0) {
    Indi_TDI *_indi = GetIndicator();
    int _ishift = _shift + ::TDI_Indi_TDI_Shift;
    bool _result =
        _indi.GetFlag(INDI_ENTRY_FLAG_IS_VALID, _ishift) && _indi.GetFlag(INDI_ENTRY_FLAG_IS_VALID, _ishift + 1);
    if (!_result) {
      // Returns false when indicator data is not valid.
      return false;
    }
    switch (_cmd) {
      case ORDER_TYPE_BUY:
        // Buy signal.
        // Trade Long when RSI PL > TSL
        _result &= _indi[(int)TDI_RSI_MA_LINE][_ishift] > _indi[(int)TDI_TRADE_SIGNAL_LINE][_ishift];
        _result &= _indi.IsIncreasing(1, TDI_RSI_MA_LINE, _ishift);
        _result &= _indi.IsIncByPct(_level, 0, _ishift, 2);
        break;
      case ORDER_TYPE_SELL:
        // Sell signal.
        // Trade Short when RSI PL < TSL
        _result &= _indi[(int)TDI_RSI_MA_LINE][_ishift] < _indi[(int)TDI_TRADE_SIGNAL_LINE][_ishift];
        _result &= _indi.IsDecreasing(1, TDI_RSI_MA_LINE, _ishift);
        _result &= _indi.IsDecByPct(_level, 0, _ishift, 2);
        break;
    }
    return _result;
  }


  /**
   * Checks strategy's trade close signal.
   *
   * @result bool
   *   Returns true when trade should be closed, otherwise false.
   */
  virtual bool SignalClose(ENUM_ORDER_TYPE _cmd, int _method = 0, float _level = 0.0f, int _shift = 0) {
    Indi_TDI *_indi = GetIndicator();
    int _ishift = _shift + ::TDI_Indi_TDI_Shift;
    bool _result =
        _indi.GetFlag(INDI_ENTRY_FLAG_IS_VALID, _ishift) && _indi.GetFlag(INDI_ENTRY_FLAG_IS_VALID, _ishift + 1);
    if (!_result) {
      // Returns false when indicator data is not valid.
      return false;
    }
    switch (_cmd) {
      case ORDER_TYPE_BUY:
        // Close long trade.
        // Exit trade when RSI PL & TSL crossover.
        _result &= _indi[(int)TDI_RSI_MA_LINE][_ishift] < _indi[(int)TDI_TRADE_SIGNAL_LINE][_ishift];
        _result &= _indi[(int)TDI_RSI_MA_LINE][_ishift + 2] > _indi[(int)TDI_TRADE_SIGNAL_LINE][_ishift + 2];
        _result &= _indi.IsDecreasing(1, TDI_RSI_MA_LINE, _ishift);
        //_result &= _indi.IsIncByPct(_level, 0, _shift, 2);
        break;
      case ORDER_TYPE_SELL:
        // Close short trade.
        // Exit trade when RSI PL & TSL crossover.
        _result &= _indi[(int)TDI_RSI_MA_LINE][_ishift] > _indi[(int)TDI_TRADE_SIGNAL_LINE][_ishift];
        _result &= _indi[(int)TDI_RSI_MA_LINE][_ishift + 2] < _indi[(int)TDI_TRADE_SIGNAL_LINE][_ishift + 2];
        _result &= _indi.IsIncreasing(1, TDI_RSI_MA_LINE, _ishift);
        //_result &= _indi.IsDecByPct(_level, 0, _shift, 2);
        break;
    }
    return _result;
  }

};
