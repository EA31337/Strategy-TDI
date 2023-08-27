//+------------------------------------------------------------------+
//|                                 Copyright 2016-2023, EA31337 Ltd |
//|                                       https://github.com/EA31337 |
//+------------------------------------------------------------------+

/*
 * This file is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 */

// Prevents processing the same indicator file twice.
#ifndef INDI_TDI_RT_MQH
#define INDI_TDI_RT_MQH

// Defines
#ifndef INDI_TDI_RT_PATH
#define INDI_TDI_RT_PATH "indicators-other\\Oscillators\\Multi\\TDI-RT-Clone"
#endif

// Indicator line identifiers used in the indicator.
enum ENUM_TDI_RT_MODE {
  TDI_RT_VOLA_TOP = 0,       // Volatility Top
  TDI_RT_VOLA_BTM,           // Volatility Bottom
  TDI_RT_MARKET_BASE,        // Market Base
  TDI_RT_TRADE_SIGNAL_LINE,  // Trade Signal Line
  TDI_RT_RSI_SIGNAL_LINE,    // RSI Signal Line
  TDI_RT_RSI_LINE,           // RSI line
  FINAL_TDI_RT_MODE_ENTRY,
};

// Structs.

// Defines struct to store indicator parameter values.
struct IndiTDIRTarams : public IndicatorParams {
  // Indicator params.
  int rsi_period;
  ENUM_APPLIED_PRICE rsi_signal_applied_price;
  int volatility_band;
  int rsi_signal_applied_price_line;
  ENUM_MA_METHOD rsi_signal_ma_method;
  int trade_signal_line;
  ENUM_MA_METHOD trade_signal_ma_method;
  // Struct constructors.
  IndiTDIRTarams(int _rsi_period = 13, ENUM_APPLIED_PRICE _rsi_signal_applied_price = 0, int _volatility_band = 34,
                 int _rsi_signal_applied_price_line = 2, ENUM_MA_METHOD _rsi_signal_ma_method = MODE_SMA,
                 int _trade_signal_line = 7, ENUM_MA_METHOD _trade_signal_ma_method = MODE_SMA, int _shift = 0)
      : rsi_period(_rsi_period),
        rsi_signal_applied_price(_rsi_signal_applied_price),
        volatility_band(_volatility_band),
        rsi_signal_applied_price_line(_rsi_signal_applied_price_line),
        rsi_signal_ma_method(_rsi_signal_ma_method),
        trade_signal_line(_trade_signal_line),
        trade_signal_ma_method(_trade_signal_ma_method),
        IndicatorParams(INDI_CUSTOM, FINAL_TDI_RT_MODE_ENTRY, TYPE_DOUBLE) {
#ifdef __resource__
    custom_indi_name = "::" + INDI_TDI_RT_PATH;
#else
    custom_indi_name = "TDI-RT-Clone";
#endif
    SetDataSourceType(IDATA_ICUSTOM);
  };

  IndiTDIRTarams(IndiTDIRTarams &_params, ENUM_TIMEFRAMES _tf) {
    THIS_REF = _params;
    tf = _tf;
  }
  // Getters.
  int GetRSIPeriod() { return rsi_period; }
  int GetRSISignalAppliedPrice() { return rsi_signal_applied_price; }
  int GetVolatilityBand() { return volatility_band; }
  int GetRSIPriceLine() { return rsi_signal_applied_price_line; }
  int GetRSISignalMAMethod() { return rsi_signal_ma_method; }
  int GetTradeSignalLine() { return trade_signal_line; }
  int GetTradeSignalMAMethod() { return trade_signal_ma_method; }
  // Setters.
  void SetRSIPeriod(int _value) { rsi_period = _value; }
  void SetRSISignalAppliedPrice(int _value) { rsi_signal_applied_price = _value; }
  void SetVolatilityBand(int _value) { volatility_band = _value; }
  void SetRSIPriceLine(int _value) { rsi_signal_applied_price_line = _value; }
  void SetRSISignalMAMethod(int _value) { rsi_signal_ma_method = _value; }
  void SetTradeSignalLine(int _value) { trade_signal_line = _value; }
  void SetTradeSignalMAMethod(int _value) { trade_signal_ma_method = _value; }
};

/**
 * Implements indicator class.
 */
class Indi_TDI_RT : public Indicator<IndiTDIRTarams> {
 public:
  /**
   * Class constructor.
   */
  Indi_TDI_RT(IndiTDIRTarams &_p, IndicatorBase *_indi_src = NULL) : Indicator<IndiTDIRTarams>(_p, _indi_src) {}
  Indi_TDI_RT(ENUM_TIMEFRAMES _tf = PERIOD_CURRENT) : Indicator(INDI_CUSTOM, _tf){};

  /**
   * Returns the indicator's value.
   *
   */
  IndicatorDataEntryValue GetEntryValue(int _mode = 0, int _shift = -1) {
    double _value = EMPTY_VALUE;
    int _ishift = _shift >= 0 ? _shift : iparams.GetShift();
    switch (iparams.idstype) {
      case IDATA_ICUSTOM:
        _value = iCustom(istate.handle, Get<string>(CHART_PARAM_SYMBOL), Get<ENUM_TIMEFRAMES>(CHART_PARAM_TF),
                         iparams.custom_indi_name, Get<ENUM_TIMEFRAMES>(CHART_PARAM_TF), iparams.GetRSIPeriod(),
                         iparams.GetRSISignalAppliedPrice(), iparams.GetVolatilityBand(), iparams.GetRSIPriceLine(),
                         iparams.GetRSISignalMAMethod(), iparams.GetTradeSignalLine(), iparams.GetTradeSignalMAMethod(),
                         _mode, _ishift);
        break;
      default:
        SetUserError(ERR_INVALID_PARAMETER);
        _value = EMPTY_VALUE;
        break;
    }
    return _value;
  }

  /**
   * Checks if indicator entry values are valid.
   */
  virtual bool IsValidEntry(IndicatorDataEntry &_entry) {
    return Indicator<IndiTDIRTarams>::IsValidEntry(_entry) && _entry.GetMin<double>() > 0 &&
           _entry.values[(int)TDI_RT_UP_LINE].IsGt<double>(_entry[(int)TDI_RT_DN_LINE]);
  }
};

#endif  // INDI_TDI_RT_MQH
