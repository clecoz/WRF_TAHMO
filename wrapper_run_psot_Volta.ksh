#!/bin/ksh -aeux
#########################################################################
# Script: wrapper_run_gsi_psot.ksh
#
# Purpose: Wrapper for WPS 
#
# Author:  Syed RH Rizvi, MMM/ESSL/NCAR,  Date:04/15/2009
#########################################################################
#export PROJECT=48503002   #DATC ????????????


#export WALLCLOCK=5	#?????????????????
#export QUEUE=premium	#?????????????????
#export NUM_PROCS=8 
set echo
#------------------------------------------------------------------------
# Having run psot set follwing variable true to draw plots, 
# otherwise set it to false                                 
#
#export RUN_PLOT_PSOT=true  
#------------------------------------------------------------------------

export REGION=volta
export EXPT=24hforecast
#Directories:
export        DAT_DIR=/home/camille/DATA        
export        REG_DIR=$DAT_DIR/$REGION              
#export        RC_DIR=$REG_DIR/rc
#export        OB_DIR=$REG_DIR/ob
export	      WPS_DIR=/home/camille/Build_WRF/WPS
export 		REL_DIR=/home/camille/Build_WRF
#export WRF_DIR
#export WRFDA_DIR
#export WRF_INPUT_DIR=${WRF_INPUT_DIR:-$RC_DIR}

#export	      RUN_DIR=/home/camille/WRF_TAHMO/wps
#export		RUN_DIR=$REG_DIR/$EXPT/wps
export		RUN_DIR_g=$REG_DIR/$EXPT
export        SCRIPTS_DIR=/home/camille/WRF_TAHMO

#export		RUN_CMD="mpirun -np 6"
export		NUM_PROCS=4
export		SUBMIT=none


#rm -rf $RUN_DIR_g

#-------------------------------------------------------------------------
#Time info
export DATE=2006072300
export INITIAL_DATE=2006072400
#export   FINAL_DATE=2006072400	#$INITIAL_DATE
export	FCST_RANGE=24
export	LBC_FREQ=6	#default value


#-------------------------------------------------------------------------


#---------------------------RUNNING WPS----------------------------------------------


export NL_MAX_DOM=2
export DOMAINS={01,02,03} 
export NL_E_WE=163,184,184
export NL_E_SN=163,217,280
export NL_E_VERT=51,51,51
if [[ $NL_MAX_DOM > 1 ]]; then
  export NL_PARENT_ID=1,1,2
  export NL_PARENT_GRID_RATIO=1,3,3
  export NL_I_PARENT_START=1,51,91
  export NL_J_PARENT_START=1,21,31
fi
export MAP_PROJ=lambert
export REF_LAT=16.0
export REF_LON=-2.0
export TRUELAT1=16.0
export TRUELAT2=-2.0
export STAND_LON=-2.0
export NL_DX=27000
export NL_DY=27000

export GEOG_DATA_RES=default
#export WPS_GEOG_DIR=/home/camille/Build_WRF/WPS_GEOG
#export VTABLE_TYPE=GFS
#export METGRID_TABLE_TYPE=ARW


export RUN_DIR=$RUN_DIR_g/wps
rm -rf $RUN_DIR

./da_run_wps.ksh
RC=$?
if [[ $RC != 0 ]]; then
      echo "ERROR in run_wps.ksh"
      exit 1
fi

#-------------------------RUNNING real------------------------------------------------
#export WRF_DIR=/home/camille/Build_WRF/WRFV3

export NL_NUM_METGRID_LEVELS=27
export NL_NUM_METGRID_SOIL_LEVELS=4
export NL_P_TOP_REQUESTED=5000
export NL_FRAMES_PER_OUTFILE=3,3,3
export NL_HISTORY_INTERVAL=60,60,60
export NL_INPUT_FROM_FILE=.true.,.true.,.true.
export NL_TIME_STEP=120
#export NL_ETA_LEVEL=
export NL_SMOOTH_OPTION=0

export NL_DX=27000,9000,3000
export NL_DY=27000,9000,3000
#set DX1 
#echo $NL_DX | cut -d"," -f1 
#export DX1=`echo $NL_DX | cut -d"," -f1` 
#echo $NL_DX
#echo $DX1
export NL_MP_PHYSICS=4,4,4
export NL_RADT=3,3,3
export NL_SF_SFCLAY_PHYSICS=1,1,1
export NL_SF_SURFACE_PHYSICS=2,2,2
export NL_NUM_SOIL_LAYERS=4
export NL_BL_PBL_PHYSICS=1,1,1
export NL_BLDT=0,0,0
export NL_CU_PHYSICS=1,1,0
export NL_CUDT=5,5,0
export NL_RA_LW_PHYSICS=1,1,1
export NL_RA_SW_PHYSICS=1,1,1
export NL_MP_ZERO_OUT=0
export NL_W_DAMPING=0
export NL_DIFF_OPT=1
export NL_KM_OPT=4,4,4
export NL_BASE_TEMP=290.
export NL_DAMPCOEF=0.2
#export NL_TIME_STEP_SOUND=
export NL_SPECIFIED=.true.
if [[ $NL_MAX_DOM > 1 ]]; then
export NL_GRID_ID=1,2,3
export NL_NESTED=.false.,.true.,.true.
fi

# Using SST
export USE_SST=1
if [[ $USE_SST = 1 ]]; then
	export NL_SST_UPDATE=1
	export NL_AUXINPUT4_INNAME="wrflowinp_d<domain>"
	export NL_AUXINPUT4_INTERVAL=360,360,360
	export NL_IO_FORM_AUXINPUT4=2
fi


export RUN_DIR=$RUN_DIR_g/real
rm -rf $RUN_DIR

./da_run_real.ksh 
RC=$?
if [[ $RC != 0 ]]; then
      echo "ERROR in run_real.ksh : namelist.input or real.exe failed..."
      exit 1
fi

#--------------------------RUNNING WRF------------------------------------

# Adaptive time step
export USE_ADAPTIVE_TIME_STEP=1
if [[ $USE_ADAPTIVE_TIME_STEP = 1 ]]; then
   export NL_USE_ADAPTIVE_TIME_STEP=.true.
   export NL_STEP_TO_OUTPUT_TIME=.true.
   export NL_TARGET_CFL=1.2,1.2,1.2
   export NL_TARGET_HCFL=0.84,0.84,0.84
   export NL_MAX_STEP_INCREASE_PCT=5,51,51
   export NL_STARTING_TIME_STEP=-1,-1,-1
   export NL_MAX_TIME_STEP=300,240,180
   export NL_MIN_TIME_STEP=-1,-1,-1
   export NL_ADAPTATION_DOMAIN=1
   export NL_ADJUST_OUTPUT_TIMES=.true.
fi

# Files format
export NL_IO_FORM_HISTORY=2	#2=NetCDF 102=split netCDF 1=binary format 4=PHDF5 format 5=GRIB1 10=GRIB2 11=parallel netCDF
export NL_IO_FORM_INPUT=2	#2=NetCDF 102=split netCDF
export NL_IO_FORM_BOUNDARY=2	#2=NetCDF 4=PHD5 5=GRIB1 10=GRIB2 11=pnetCDF

# Writting input-formatted data as output for WRFDA application
#export NL_WRITE_INPUT=.true.
#export NL_INPUTOUT_INTERVAL=
#export NL_INPUTOUT_BEGIN_H=
#export NL_INPUTOUT_END_H=
export NL_INPUT_OUTNAME="wrfvar_input_d<domain>_<date>"

export RUN_DIR=$RUN_DIR_g/wrf
rm -rf $RUN_DIR

#./run_wrf.ksh
./da_run_wrf.ksh
RC=$?
if [[ $RC != 0 ]]; then
      echo "ERROR in run_real.ksh : namelist or wrf.exe failed..."
      exit 1
fi
#-------------------------------------------------------------------------
