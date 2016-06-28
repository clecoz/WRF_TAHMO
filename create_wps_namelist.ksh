#!/bin/ksh
#-----------------------------------------------------------------------
# Script: da_create_wps_namelist.ksh
#
# Purpose: Create namelist for running WPS.

#-----------------------------------------------------------------------
# [1] Set defaults for required environment variables:
#-----------------------------------------------------------------------

export REL_DIR=${REL_DIR:-$HOME/WRF}
export WRFVAR_DIR=${WRFVAR_DIR:-$REL_DIR/WRFDA}
export SCRIPTS_DIR=${SCRIPTS_DIR:-/run/media/aliabbasi/Data2/WRF_Auto_02}
. ${SCRIPTS_DIR}/set_defaults.ksh

#-----------------------------------------------------------------------
# [2] Get date range: 
#-----------------------------------------------------------------------

. ${SCRIPTS_DIR}/get_date_range.ksh

cat >namelist.wps <<EOF
&share
 wrf_core = 'ARW',
 max_dom = $MAX_DOMAINS,
 start_year = $NL_START_YEAR,
 start_month = $NL_START_MONTH,
 start_day = $NL_START_DAY,
 start_hour = $NL_START_HOUR,
 end_year = $NL_END_YEAR,
 end_month = $NL_END_MONTH,
 end_day = $NL_END_DAY,
 end_hour = $NL_END_HOUR,
 interval_seconds = $LBC_FREQ_SS,
 io_form_geogrid = 2,
 opt_output_from_geogrid_path = '$WPS_OUTPUT_DIR',
 debug_level = $NL_DEBUG_LEVEL
/

&geogrid
 parent_id =           $PARENT_ID01, $PARENT_ID02, $PARENT_ID03,
 parent_grid_ratio =   $PARENT_GRID_RATIO01,$PARENT_GRID_RATIO02,$PARENT_GRID_RATIO03,
 i_parent_start =      $I_PARENT_START01,$I_PARENT_START02,$I_PARENT_START03,
 j_parent_start =      $J_PARENT_START01,$J_PARENT_START02,$J_PARENT_START03,
 s_we           = 1,1,1,
 e_we           = $NL_E_WE01,$NL_E_WE02,$NL_E_WE03,
 s_sn           = 1,1,1,
 e_sn           = $NL_E_SN01,$NL_E_SN02,$NL_E_SN03,
 geog_data_res  = '$GEOG_DATA_RES01', '$GEOG_DATA_RES02' , '$GEOG_DATA_RES03',
 dx = $NL_DX,
 dy = $NL_DY,
 map_proj = '$MAP_PROJ',
 ref_lat   = $REF_LAT,
 ref_lon   = $REF_LON,
EOF

if [[ ! -z "$REF_X" ]]; then
   echo " ref_x     = $REF_X," >> namelist.wps
fi
if [[ ! -z "$REF_Y" ]]; then
   echo " ref_y     = $REF_Y," >> namelist.wps
fi

cat >>namelist.wps <<EOF
 truelat1  = $TRUELAT1,
 truelat2  = $TRUELAT2,
 stand_lon = $STAND_LON,
 geog_data_path = '$WPS_GEOG_DIR',
 opt_geogrid_tbl_path = '$WPS_DIR/geogrid'
/

&ungrib
 out_format = 'WPS'
/

&metgrid
 fg_name = './FILE'
 constants_name = '$CONSTANTS1', '$CONSTANTS2'
 io_form_metgrid = 2, 
 opt_output_from_metgrid_path = '$WPS_OUTPUT_DIR/$DATE',
 opt_metgrid_tbl_path         = './',
 opt_ignore_dom_center        = .false.
/
EOF

exit 0

