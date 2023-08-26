/*
 * @file
 * Defines default strategy parameter values for the given timeframe.
 */

// Defines indicator's parameter values for the given pair symbol and timeframe.
struct Indi_TDI_Params_M15 : IndiTDIParams {
  Indi_TDI_Params_M15() : IndiTDIParams(indi_tdi_defaults, PERIOD_M15) { shift = 0; }
} indi_tdi_m15;

// Defines strategy's parameter values for the given pair symbol and timeframe.
struct Stg_TDI_Params_M15 : StgParams {
  // Struct constructor.
  Stg_TDI_Params_M15() : StgParams(stg_tdi_defaults) {}
} stg_tdi_m15;
