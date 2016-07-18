#!/bin/ksh
#########################################################################
# Script: da_run_wrfvar.ksh
#
# Purpose: Run wrfvar
#########################################################################

export REL_DIR=${REL_DIR:-$HOME/Build_WRF}
export WRFVAR_DIR=${WRFVAR_DIR:-$REL_DIR/WRFDA}
export SCRIPTS_DIR=${SCRIPTS_DIR:-$WRFVAR_DIR/var/scripts}
. ${SCRIPTS_DIR}/da_set_defaults.ksh
export RUN_DIR=${RUN_DIR:-$EXP_DIR/wrfvar}
export DA_DIR_DATE=${DA_DIR_DATE:-$DA_DIR/$DATE}

if [[ ! -d $DA_DIR_DATE ]]; then mkdir -p $DA_DIR_DATE; fi

export WORK_DIR=$RUN_DIR/working

export WINDOW_START=${WINDOW_START:--3}
export WINDOW_END=${WINDOW_END:-3}
export FGATOBS_FREQ=${FGATOBS_FREQ:-1}
export DOMAIN=${DOMAIN:-01}

export YEAR=$(echo $DATE | cut -c1-4)
export MONTH=$(echo $DATE | cut -c5-6)
export DAY=$(echo $DATE | cut -c7-8)
export HOUR=$(echo $DATE | cut -c9-10)
export PREV_DATE=$($BUILD_DIR/da_advance_time.exe $DATE -$CYCLE_PERIOD 2>/dev/null)
export ANALYSIS_DATE=${YEAR}-${MONTH}-${DAY}_${HOUR}:00:00
export NL_ANALYSIS_DATE=${ANALYSIS_DATE}.0000

export DA_FIRST_GUESS=${DA_FIRST_GUESS:-${RC_DIR}/$DATE/wrfinput_d${DOMAIN}}
if $CYCLING; then
   if [[ $CYCLE_NUMBER -gt 0 ]]; then
     export DA_FIRST_GUESS=${FC_DIR}/${PREV_DATE}/${FILE_TYPE}_d${DOMAIN}_${ANALYSIS_DATE}
     export DA_FIRST_GUESS=${FC_DIR}/${PREV_DATE}/wrfvar_input_d${DOMAIN}_${ANALYSIS_DATE}
   fi
   
fi

export DA_ANALYSIS=${DA_ANALYSIS:-analysis}
#export DA_BDY_ANALYSIS=${DA_BDY_ANALYSIS:-wrfvar_bdyout}

if [[ $NL_CV_OPTIONS == 3 ]]; then
   export DA_BACK_ERRORS=$WRFVAR_DIR/var/run/be.dat.cv3
else
   export DA_BACK_ERRORS=${DA_BACK_ERRORS:-$BE_DIR/be.dat} # wrfvar background errors.
fi

# For radiance
if [[ $USE_RADIANCE_OBS = 1 ]]; then
#export RTTOV=${RTTOV:-$HOME/rttov/rttov87}                            # RTTOV
export DA_RTTOV_COEFFS=${DA_RTTOV_COEFFS:- }
#export CRTM=${CRTM:-$HOME/crtm}
export DA_CRTM_COEFFS=${DA_CRTM_COEFFS:- }
fi

# Change defaults from Registry.wrfvar which is required to be
# consistent with WRF's Registry.EM
#export NL_INTERP_TYPE=${NL_INTERP_TYPE:-1}
#export NL_T_EXTRAP_TYPE=${NL_T_EXTRAP_TYPE:-1}
#export NL_I_PARENT_START=${NL_I_PARENT_START:-0}
#export NL_J_PARENT_START=${NL_J_PARENT_START:-0}
#export NL_JCDFI_USE=${NL_JCDFI_USE:-false}
#export NL_CO2TF=${NL_CO2TF:-0}
#export NL_W_SPECIFIED=${NL_W_SPECIFIED:-true}	??????????????
#export NL_REAL_DATA_INIT_TYPE=${NL_REAL_DATA_INIT_TYPE:-3}	??????????????/

#=======================================================

mkdir -p $RUN_DIR


date

echo 'REL_DIR               <A HREF="file:'$REL_DIR'">'$REL_DIR'</a>'
echo 'WRFVAR_DIR            <A HREF="file:'$WRFVAR_DIR'">'$WRFVAR_DIR'</a>' $WRFVAR_VN
if $NL_VAR4D; then
   echo 'WRFPLUS_DIR           <A HREF="file:'$WRFPLUS_DIR'">'$WRFPLUS_DIR'</a>' $WRFPLUS_VN
fi
echo "DA_BACK_ERRORS        $DA_BACK_ERRORS"

if [[ $USE_RADIANCE_OBS = 1 ]]; then
if [[ -d $DA_RTTOV_COEFFS ]]; then
   echo "DA_RTTOV_COEFFS       $DA_RTTOV_COEFFS"
fi
if [[ -d $DA_CRTM_COEFFS ]]; then
   echo "DA_CRTM_COEFFS        $DA_CRTM_COEFFS"
fi
#if [[ -d $BIASCORR_DIR ]]; then
#   echo "BIASCORR_DIR          $BIASCORR_DIR"
#fi
#if [[ -d $OBS_TUNING_DIR ]] ; then
#   echo "OBS_TUNING_DIR        $OBS_TUNING_DIR"
#fi
# Radiance
if [[ -f $DA_VARBC_IN ]]; then
   echo "DA_VARBC_IN          $DA_VARBC_IN"
fi
fi

echo 'OB_DIR                <A HREF="file:'$OB_DIR'">'$OB_DIR'</a>'
echo 'RC_DIR                <A HREF="file:'$RC_DIR'">'$RC_DIR'</a>'
echo 'FC_DIR                <A HREF="file:'$FC_DIR'">'$FC_DIR'</a>'
echo 'DA_DIR                <A HREF="file:'$DA_DIR'">'$DA_DIR'</a>' 
echo 'RUN_DIR               <A HREF="file:'.'">'$RUN_DIR'</a>'
echo 'WORK_DIR              <A HREF="file:'${WORK_DIR##$RUN_DIR/}'">'$WORK_DIR'</a>'
echo "DA_ANALYSIS           $DA_ANALYSIS"
#echo "DA_BDY_ANALYSIS       $DA_BDY_ANALYSIS"
echo "DATE                  $DATE"
echo "WINDOW_START          $WINDOW_START"
echo "WINDOW_END            $WINDOW_END"

rm -rf ${WORK_DIR}
mkdir -p ${WORK_DIR}
cd $WORK_DIR

START_DATE=$($BUILD_DIR/da_advance_time.exe $DATE $WINDOW_START)
END_DATE=$($BUILD_DIR/da_advance_time.exe $DATE $WINDOW_END)

#for INDEX in 01 02 03 04 05 06 07; do
#   let H=$INDEX-1+$WINDOW_START
#   D_DATE[$INDEX]=$($BUILD_DIR/da_advance_time.exe $DATE $H)
#   export D_YEAR[$INDEX]=$(echo ${D_DATE[$INDEX]} | cut -c1-4)
#   export D_MONTH[$INDEX]=$(echo ${D_DATE[$INDEX]} | cut -c5-6)
#   export D_DAY[$INDEX]=$(echo ${D_DATE[$INDEX]} | cut -c7-8)
#   export D_HOUR[$INDEX]=$(echo ${D_DATE[$INDEX]} | cut -c9-10)
#done

export YEAR=$(echo $DATE | cut -c1-4)
export MONTH=$(echo $DATE | cut -c5-6)
export DAY=$(echo $DATE | cut -c7-8)
export HOUR=$(echo $DATE | cut -c9-10)

export NL_START_YEAR=$YEAR
export NL_START_MONTH=$MONTH
export NL_START_DAY=$DAY
export NL_START_HOUR=$HOUR

export NL_END_YEAR=$YEAR
export NL_END_MONTH=$MONTH
export NL_END_DAY=$DAY
export NL_END_HOUR=$HOUR

export START_YEAR=$(echo $START_DATE | cut -c1-4)
export START_MONTH=$(echo $START_DATE | cut -c5-6)
export START_DAY=$(echo $START_DATE | cut -c7-8)
export START_HOUR=$(echo $START_DATE | cut -c9-10)

export END_YEAR=$(echo $END_DATE | cut -c1-4)
export END_MONTH=$(echo $END_DATE | cut -c5-6)
export END_DAY=$(echo $END_DATE | cut -c7-8)
export END_HOUR=$(echo $END_DATE | cut -c9-10)

export NL_TIME_WINDOW_MIN=${NL_TIME_WINDOW_MIN:-${START_YEAR}-${START_MONTH}-${START_DAY}_${START_HOUR}:00:00.0000}
export NL_TIME_WINDOW_MAX=${NL_TIME_WINDOW_MAX:-${END_YEAR}-${END_MONTH}-${END_DAY}_${END_HOUR}:00:00.0000}



#-----------------------------------------------------------------------
# [2.0] Perform sanity checks:
#-----------------------------------------------------------------------

if [[ ! -f $DA_FIRST_GUESS ]]; then
   echo "${ERR}First Guess file >$DA_FIRST_GUESS< does not exist:$END"
   exit 1
fi

if [[ ! -d $OB_DIR ]]; then
   echo "${ERR}Observation directory >$OB_DIR< does not exist:$END"
   exit 1
fi

if [[ $NL_ANALYSIS_TYPE != "VERIFY" ]] ; then
  if [[ ! -r $DA_BACK_ERRORS ]]; then
   echo "${ERR}Background Error file >$DA_BACK_ERRORS< does not exist:$END"
   exit 1
  fi
fi

#-----------------------------------------------------------------------
# [3.0] Prepare for assimilation:
#-----------------------------------------------------------------------

# Radiance
if [[ $USE_RADIANCE_OBS = 1 ]]; then
if [[ -d $DA_RTTOV_COEFFS ]]; then
   ln -fs $DA_RTTOV_COEFFS/* .
fi

if [[ -d $DA_CRTM_COEFFS ]]; then
   ln -fs $DA_CRTM_COEFFS ./crtm_coeffs
fi

if [[ -f $DA_VARBC_IN ]]; then
   ln -fs $DA_VARBC_IN "VARBC.in"	#./VARBC.in ??????
fi


export RADIANCE_INFO_DIR=${RADIANCE_INFO_DIR:-$WRFVAR_DIR/var/run/radiance_info}
ln -fs $RADIANCE_INFO_DIR ./radiance_info
fi

#if [[ $DATE -lt 2007081412 ]]; then
#   ln -fs $WRFVAR_DIR/var/run/gmao_airs_bufr.tbl ./gmao_airs_bufr.tbl
#else
#   ln -fs $WRFVAR_DIR/var/run/gmao_airs_bufr.tbl_new ./gmao_airs_bufr.tbl
#fi

ln -fs $WRFVAR_DIR/run/LANDUSE.TBL .
ln -fs $BUILD_DIR/da_wrfvar.exe .
#export PATH=$WRFVAR_DIR/var/scripts:$PATH

cp -p $DA_FIRST_GUESS fg 
if $CYCLING; then
   if [[ $CYCLE_NUMBER -gt 0 ]]; then
     ${SCRIPTS_DIR}/update_low_bc.ksh
     RC=$?
     if [[ $RC != 0 ]]; then
       echo "ERROR in run_wrfvar2.ksh : update low bdy failed..."
       exit 1
     fi
   fi
fi

#ln -fs $DA_FIRST_GUESS fg 
#ln -fs $DA_FIRST_GUESS ${FILE_TYPE}_d01
#if [[ $NL_ANALYSIS_TYPE != "VERIFY" ]] ; then
  ln -fs $DA_BACK_ERRORS be.dat
#fi

#if [[ -d $EP_DIR ]]; then
#   ln -fs $EP_DIR ep
#fi

#if [[ -d $BIASCORR_DIR ]]; then
#   ln -fs $BIASCORR_DIR biascorr
#fi

#if [[ -d $OBS_TUNING_DIR ]]; then
#   ln -fs $OBS_TUNING_DIR/* .
#fi

#if [[ $NL_NUM_FGAT_TIME -gt 1 ]]; then
#      typeset -i N
#      let N=0
#      FGAT_DATE=$START_DATE
#      until [[ $FGAT_DATE > $END_DATE ]]; do
#         let N=$N+1
#         ln -fs $OB_DIR/$FGAT_DATE/ob.ascii ob0${N}.ascii
#         if [[ -s $OB_DIR/$FGAT_DATE/ob.ssmi ]]; then
#            ln -fs $OB_DIR/$FGAT_DATE/ob.ssmi ob0${N}.ssmi
#         fi
#         if [[ -s $OB_DIR/$FGAT_DATE/ob.radar ]]; then
#            ln -fs $OB_DIR/$FGAT_DATE/ob.radar ob0${N}.radar
#         fi
#         FYEAR=$(echo ${FGAT_DATE} | cut -c1-4)
#         FMONTH=$(echo ${FGAT_DATE} | cut -c5-6)
#         FDAY=$(echo ${FGAT_DATE} | cut -c7-8)
#         FHOUR=$(echo ${FGAT_DATE} | cut -c9-10)
#         ln -fs ${FC_DIR}/${PREV_DATE}/wrfinput_d01_${FYEAR}-${FMONTH}-${FDAY}_${FHOUR}:00:00 fg0${N}
#         FGAT_DATE=$($BUILD_DIR/da_advance_time.exe $FGAT_DATE $FGATOBS_FREQ)
#      done
#
#else
#   ln -fs $OB_DIR/${DATE}/ob.ascii  ob.ascii
   if [[ -s $OB_DIR/${DATE}/ob.ssmi ]]; then
      ln -fs $OB_DIR/${DATE}/ob.ssmi ob.ssmi
   fi
   if [[ -s $OB_DIR/${DATE}/ob.radar ]]; then
      ln -fs $OB_DIR/${DATE}/ob.radar ob.radar
   fi
#fi

#for FILE in $OB_DIR/$DATE/*.bufr; do
#   if [[ -f $FILE ]]; then
#      ln -fs $FILE .
#   fi
#done

if [[ $NL_OB_FORMAT = 2 ]]; then
   ln -fs $OB_DIR/${DATE}/ascii/*  ./ob.ascii
elif [[ $NL_OB_FORMAT = 1 ]]; then
   ln -fs  $OB_DIR/${DATE}/bufr/* ./ob.bufr
else
   echo "Wrong NL_OB_FORMAT"
fi
# Radiance
if [[ $USE_RADIANCE_OBS = 1 ]]; then
#echo $OB_DIR/${DATE}/radiance/gdas.1bamua.t00z.${YEAR}${MONTH}${DAY}.bufr
if [[ $NL_USE_AMSUAOBS ]]; then
ln -fs $OB_DIR/${DATE}/radiance/gdas.1bamua.t${HOUR}z.${YEAR}${MONTH}${DAY}.bufr ./amsua.bufr
fi
if [[ $NL_USE_AIRSOBS ]]; then
ln -fs $OB_DIR/${DATE}/radiance/gdas.airsev.t${HOUR}z.${YEAR}${MONTH}${DAY}.bufr ./airs.bufr 
fi
#ln -fs $OB_DIR/${DATE}/radiance/gdas1.t00z.1bamub.tm00.bufr ./amsub.bufr
fi
. $WRFVAR_DIR/inc/namelist_script.inc 


   cp namelist.input $RUN_DIR
   echo '<A HREF="namelist.input">Namelist.input</a>'



#-------------------------------------------------------------------
#Run WRF-Var:
#-------------------------------------------------------------------
#mkdir trace

if $DUMMY; then
   echo Dummy wrfvar
   echo "Dummy wrfvar" > $DA_ANALYSIS
   RC=0
else
      # 3DVAR
      $RUN_CMD ./da_wrfvar.exe
      RC=$?
#   fi


if $CYCLING; then
   if [[ ${DOMAIN} == '01' ]]; then
     ${SCRIPTS_DIR}/update_lat_bc.ksh
     RC=$?
     if [[ $RC != 0 ]]; then
       echo "ERROR in run_wrfvar2.ksh : update lat bdy failed..."
       exit 1
     fi
    fi
fi


# temporarily store the high resolution reults in RUN_DIR
   
#   if [[ -f fort.9 ]]; then
#      cp fort.9 $RUN_DIR/namelist.output
#   fi
   if [[ -f namelist.output.da ]]; then
      cp namelist.output.da $RUN_DIR/namelist.output
   fi
   if [[ -f statistics ]]; then
      cp statistics $RUN_DIR
   fi

   for INDEX in 01 02 03 04 05 06 07 08 09 10; do
      if [[ -f rej_obs_conv_$INDEX.0000 ]]; then
         cat rej_obs_conv_$INDEX.* > rej_obs_conv_$INDEX
         cp rej_obs_conv_$INDEX $RUN_DIR
      fi
     if [[ -f qcstat_conv_$INDEX ]]; then
     cp qcstat_conv_$INDEX $RUN_DIR
     fi
     if [[ -f gts_omb_oma_$INDEX ]]; then
     cp gts_omb_oma_$INDEX $RUN_DIR
     fi
#     if [[ -f filtered_obs_$INDEX ]]; then
#        cp filtered_obs_$INDEX $RUN_DIR
#     fi
   done 

   if [[ -f analysis_increments ]]; then
      cp analysis_increments $RUN_DIR
   fi
   if [[ -f cost_fn ]]; then 
      cp cost_fn $RUN_DIR
   fi
   if [[ -f grad_fn ]]; then
      cp grad_fn $RUN_DIR
   fi
   if [[ -f gts_omb_oma ]]; then
      cp gts_omb_oma $RUN_DIR
   fi
#   if [[ -f filtered_obs ]]; then
#      cp filtered_obs $RUN_DIR
#   fi
   if [[ -f jo ]]; then
      cp jo $RUN_DIR
   fi
   if [[ -f unpert_obs ]]; then
      cp unpert_obs $RUN_DIR
   fi
   if [[ -f check_max_iv ]]; then
      cp check_max_iv $RUN_DIR
   fi
#   if [[ -f ob.etkf.000 ]]; then
#      cp ob.etkf.000 $RUN_DIR
#   fi
   if (ls qcstat_* 2>/dev/null); then
      cp qcstat_* $RUN_DIR
   fi
   if [[ -f rsl.out.0000 ]]; then
      cp rsl.out.0000 $RUN_DIR
   fi
#   if [[ -f VARBC.in ]]; then
#      cp VARBC.in $RUN_DIR
#   fi
#   if [[ -f VARBC.out ]]; then
#      cp VARBC.out $RUN_DIR
#   fi
#   if (ls biasprep* 2>/dev/null); then
#      mkdir $RUN_DIR/biasprep
#      mv $RUN_DIR/working/biasprep* $RUN_DIR/biasprep
#   fi



#----------------------------------

# remove intermediate output files


#   if [[ -d trace ]]; then
#      mkdir -p $RUN_DIR/trace
#      mv trace/* $RUN_DIR/trace
#   fi
   rm -f unpert_obs.*
   rm -f pert_obs.*
   rm -f rand_obs_error.*
   rm -f gts_omb_oma.*
   rm -f qcstat_*.*
#   rm filtered_obs.*
   # No routine to merge these files across processors yet
   # rm -f inv_*.*
   # rm -f oma_*.*
   # rm -f filtered_*.*

#   if [[ $NL_MULTI_INC == 0 ]] ; then
      if [[ -f wrfvar_output ]]; then
         if [[ $DA_ANALYSIS != wrfvar_output ]]; then 
#            if ! $RUN_ADJ_SENS; then
               cp wrfvar_output $DA_ANALYSIS
#               if [[ -f wrfvar_bdyout ]]; then
#                  cp wrfvar_bdyout $DA_BDY_ANALYSIS
#               fi
#            fi
         fi
      fi
#   fi

#if [[ -d $DA_DIR_DATE/d${DOMAIN} ]]; then
#   echo "Folder already exists"
#else
#   mkdir $DA_DIR_DATE/d${DOMAIN}
#fi
#mkdir -p $DA_DIR_DATE/d${DOMAIN}
if [[ ! -d $DA_DIR_DATE/d${DOMAIN} ]]; then
mkdir -p $DA_DIR_DATE/d${DOMAIN}
fi

if [[ ${DOMAIN} == '01' ]]; then
mv $WORK_DIR/wrfbdy_d${DOMAIN} $DA_DIR_DATE/wrfbdy_d${DOMAIN}
fi
cp $WORK_DIR/wrfvar_output $DA_DIR_DATE/wrfinput_d${DOMAIN}
mv $WORK_DIR/wrfvar_output $DA_DIR_DATE/d${DOMAIN}/wrfvar_output
mv $WORK_DIR/fg $DA_DIR_DATE/d${DOMAIN}/fg

 #     cp $WORK_DIR/namelist.output $RUN_DIR
      echo '<A HREF="namelist.output">Namelist.output</a>'


   if [[ -f rsl.out.0000 ]]; then
      rm -rf $RUN_DIR/rsl
      mkdir -p $RUN_DIR/rsl
      mv rsl* $RUN_DIR/rsl
      cd $RUN_DIR/rsl
      mv $RUN_DIR/rsl $DA_DIR_DATE/d${DOMAIN}/rsl
      for FILE in rsl*; do
         echo "<HTML><HEAD><TITLE>$FILE</TITLE></HEAD>" > $FILE.html
         echo "<H1>$FILE</H1><PRE>" >> $FILE.html
         cat $FILE >> $FILE.html
         echo "</PRE></BODY></HTML>" >> $FILE.html
         rm $FILE
      done
      echo '<A HREF="rsl/rsl.out.0000.html">rsl.out.0000</a>'
      echo '<A HREF="rsl/rsl.error.0000.html">rsl.error.0000</a>'
      echo '<A HREF="rsl">Other RSL output</a>'
   fi

#   echo '<A HREF="trace/0.html">PE 0 trace</a>'
#   echo '<A HREF="trace">Other tracing</a>'
   echo '<A HREF="cost_fn">Cost function</a>'
   echo '<A HREF="grad_fn">Gradient function</a>'
   echo '<A HREF="statistics">Statistics</a>'

#   cat $RUN_DIR/cost_fn

   echo $(date +'%D %T') "Ended $RC"
fi

# We never look at core files

for DIR in $WORK_DIR/coredir.*; do
   if [[ -d $DIR ]]; then
      rm -rf $DIR
   fi
done

if $CLEAN; then
   rm -rf $WORK_DIR
fi

echo '</PRE></BODY></HTML>'

exit $RC
