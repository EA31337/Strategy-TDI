/*
 * @file
 * Defines default strategy parameter values for the given timeframe.
 */

// Defines indicator's parameter values for the given pair symbol and timeframe.
struct Indi_TDI_Params_M5 : IndiTDIParams {
  Indi_TDI_Params_M5() : IndiTDIParams(indi_tdi_defaults, PERIOD_M5) { shift = 0; }
} indi_tdi_m5;

// Defines strategy's parameter values for the given pair symbol and timeframe.
struct Stg_TDI_Params_M5 : StgParams {
  // Struct constructor.
  Stg_TDI_Params_M5() : StgParams(stg_tdi_defaults) {}
} stg_tdi_m5;
