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
#ifndef INDI_TDI_MQH
#define INDI_TDI_MQH

// Defines
#ifndef INDI_TDI_PATH
#define INDI_TDI_PATH "indicators-other\\Oscillators\\Multi"
#endif

// Indicator line identifiers used in the indicator.
enum ENUM_TDI_MODE {
  TDI_RSI_LINE = 0,       // RSI line
  TDI_UP_LINE,            // VB High
  TDI_MID_LINE,           // Base line
  TDI_DN_LINE,            // VB Low
  TDI_RSI_MA_LINE,        // RSI MA Price Line
  TDI_TRADE_SIGNAL_LINE,  // Trade Signal Line
  FINAL_TDI_MODE_ENTRY,
};

// Structs.

// Defines struct to store indicator parameter values.
struct IndiTDIParams : public IndicatorParams {
  // Indicator params.
  int rsi_period;
  int rsi_price;
  int volatility_band;
  int rsi_price_line;
  int rsi_price_type;
  int trade_signal_line;
  int trade_signal_type;
  // Struct constructors.
  IndiTDIParams(int _rsi_period = 13, int _rsi_price = 0, int _volatility_band = 34, int _rsi_price_line = 2,
                int _rsi_price_type = 0, int _trade_signal_line = 7, int _trade_signal_type = 0, int _shift = 0)
      : rsi_period(_rsi_period),
        rsi_price(_rsi_price),
        volatility_band(_volatility_band),
        rsi_price_line(_rsi_price_line),
        rsi_price_type(_rsi_price_type),
        trade_signal_line(_trade_signal_line),
        trade_signal_type(_trade_signal_type),
        IndicatorParams(INDI_CUSTOM, FINAL_TDI_MODE_ENTRY, TYPE_DOUBLE) {
#ifdef __resource__
    custom_indi_name = "::" + INDI_TDI_PATH;
#else
    custom_indi_name = "TDI";
#endif
    SetDataSourceType(IDATA_ICUSTOM);
  };

  IndiTDIParams(IndiTDIParams &_params, ENUM_TIMEFRAMES _tf) {
    THIS_REF = _params;
    tf = _tf;
  }
  // Getters.
  int GetRSIPeriod() { return rsi_period; }
  int GetRSIPrice() { return rsi_price; }
  int GetVolatilityBand() { return volatility_band; }
  int GetRSIPriceLine() { return rsi_price_line; }
  int GetRSIPriceType() { return rsi_price_type; }
  int GetTradeSignalLine() { return trade_signal_line; }
  int GetTradeSignalType() { return trade_signal_type; }
  // Setters.
  void SetRSIPeriod(int _value) { rsi_period = _value; }
  void SetRSIPrice(int _value) { rsi_price = _value; }
  void SetVolatilityBand(int _value) { volatility_band = _value; }
  void SetRSIPriceLine(int _value) { rsi_price_line = _value; }
  void SetRSIPriceType(int _value) { rsi_price_type = _value; }
  void SetTradeSignalLine(int _value) { trade_signal_line = _value; }
  void SetTradeSignalType(int _value) { trade_signal_type = _value; }
};

/**
 * Implements indicator class.
 */
class Indi_TDI : public Indicator<IndiTDIParams> {
 public:
  /**
   * Class constructor.
   */
  Indi_TDI(IndiTDIParams &_p, IndicatorBase *_indi_src = NULL) : Indicator<IndiTDIParams>(_p, _indi_src) {}
  Indi_TDI(ENUM_TIMEFRAMES _tf = PERIOD_CURRENT) : Indicator(INDI_CUSTOM, _tf){};

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
                         iparams.GetRSIPrice(), iparams.GetVolatilityBand(), iparams.GetRSIPriceLine(),
                         iparams.GetRSIPriceType(), iparams.GetTradeSignalLine(), iparams.GetTradeSignalType(), _mode,
                         _ishift);
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
    return Indicator<IndiTDIParams>::IsValidEntry(_entry) && _entry.GetMin<double>() > 0 &&
           _entry.values[(int)TDI_UP_LINE].IsGt<double>(_entry[(int)TDI_DN_LINE]);
  }
};

#endif  // INDI_TDI_MQH
