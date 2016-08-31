#!/bin/ksh
#########################################################################
# Script: da_run_wrf.ksh
#
# Purpose: Run WRF system.
#########################################################################

#########################################################################
# Ideally, you should not need to change the code below, but if you 
# think it necessary then please email wrfhelp@ucar.edu with details.
#########################################################################

# Option to run WRF, WRFNL, WRFTL and WRFAD
#if [[ $# -gt 0 ]]; then WRF_CONF=$1; else WRF_CONF=""; fi
#echo "Running WRF Configuration: WRF"$WRF_CONF

export REL_DIR=${REL_DIR:-$HOME/Build_WRF}
export WRF_DIR=${WRF_DIR:-$REL_DIR/WRFV3}
export SCRIPTS_DIR=${SCRIPTS_DIR:-$WRFVAR_DIR/var/scripts}
echo $NL_WRITE_INPUT
. ${SCRIPTS_DIR}/da_set_defaults.ksh
echo $NL_WRITE_INPUT
export RUN_DIR=${RUN_DIR:-$EXP_DIR/wrf}
export WORK_DIR=$RUN_DIR/working
export NL_RUN_HOURS=$FCST_RANGE
export FC_DIR_DATE=${FC_DIR_DATE:-$FC_DIR/$DATE}
export WRF_INPUT_DIR=${WRF_INPUT_DIR:-$RC_DIR}


if [[ ! -d $FC_DIR_DATE ]]; then mkdir -p $FC_DIR_DATE; fi
if [[ $WRF_CONF == "" ]]; then rm -rf $WORK_DIR; fi
mkdir -p $RUN_DIR $WORK_DIR
cd $WORK_DIR

# Writting output for WRFDA
export NL_INPUTOUT_BEGIN_H=${NL_INPUTOUT_BEGIN_H:-0}
export NL_INPUTOUT_END_H=${NL_INPUTOUT_END_H:-$FCST_RANGE}
#export NL_INPUTOUT_END_H=$FCST_RANGE
export NL_INPUTOUT_INTERVAL=60,60,60

#----- WRF -----
export EXEC_DIR=$WRF_DIR
export EXEC_FILE="wrf.exe"   


# Get extra namelist variables:
. $SCRIPTS_DIR/da_get_date_range.ksh

echo "<HTML><HEAD><TITLE>$EXPT wrf</TITLE></HEAD><BODY>"
echo "<H1>$EXPT wrf</H1><PRE>"

date

echo 'REL_DIR        <A HREF="file:'$REL_DIR'">'$REL_DIR'</a>'         
echo 'WRF'${WRF_CONF}'_DIR      <A HREF="file:'$EXEC_DIR'">'$EXEC_DIR'</a>' $WRF_VN 
echo 'RUN_DIR        <A HREF="file:'$RUN_DIR'">'$RUN_DIR'</a>'         
echo 'WORK_DIR       <A HREF="file:'$WORK_DIR'">'$WORK_DIR'</a>'       
echo 'RC_DIR         <A HREF="file:'$RC_DIR'">'$RC_DIR'</a>'           
echo 'FC_DIR_DATE    <A HREF="file:'$FC_DIR_DATE'">'$FC_DIR_DATE'</a>'              
echo 'WRF_INPUT_DIR  <A HREF="file:'$WRF_INPUT_DIR'">'$WRF_INPUT_DIR'</a>'         
echo "DATE           $DATE"                                            
echo "END_DATE       $END_DATE"                                        
echo "FCST_RANGE     $FCST_RANGE"                                      
echo "LBC_FREQ       $LBC_FREQ"  
echo "DOMAINS        $DOMAINS"
echo "MEM            $MEM"

# Copy necessary info (better than link as not overwritten):
ln -fs $EXEC_DIR/main/$EXEC_FILE .
#ln -fs $EXEC_DIR/run/gribmap.txt .	#????????????
#ln -fs $EXEC_DIR/run/ozone* .
ln -fs $EXEC_DIR/run/*.TBL .
if $DOUBLE; then
   ln -fs $EXEC_DIR/run/RRTM_DATA_DBL RRTM_DATA
   ln -fs $EXEC_DIR/run/ETAMPNEW_DATA_DBL ETAMPNEW_DATA
else
   ln -fs $EXEC_DIR/run/RRTM_DATA .
   ln -fs $EXEC_DIR/run/ETAMPNEW_DATA .
fi
ln -fs $EXEC_DIR/run/CAM_ABS_DATA .
ln -fs $EXEC_DIR/run/CAM_AEROPT_DATA .

for DOMAIN in $DOMAINS; do
   # Copy this file, so the copy back of wrfinput files later does
   # not create a recursive link
   cp $WRF_INPUT_DIR/$DATE/wrfinput_d${DOMAIN} wrfinput_d${DOMAIN}
   # WHY
   if [[ $USE_SST = 1 ]]; then
      cp ${RC_DIR}/$INITIAL_DATE/wrflowinp_d${DOMAIN} wrflowinp_d${DOMAIN}
   fi
done
cp $WRF_INPUT_DIR/$DATE/wrfbdy_d01* .

let NL_INTERVAL_SECONDS=$LBC_FREQ*3600


if [[ $USE_TSLIST = 1 ]];then
   ln -fs ${SCRIPTS_DIR}/tslist .
fi

# Create namelist.input
   . $EXEC_DIR/inc/namelist_script.inc "namelist.input"

cp namelist.input $RUN_DIR/namelist.input
echo '<A HREF="namelist.input">Namelist input</a>'

# Run wrf
   $RUN_CMD ./$EXEC_FILE

   if [[ -f rsl.out.0000 ]]; then
      grep -q 'SUCCESS COMPLETE ' $EXEC_FILE rsl.out.0000 
      RC=$?
   fi
   
# Copy different output files   
   cp namelist.output $RUN_DIR/namelist.output
   echo '<A HREF="namelist.output">Namelist output</a>'

   if [[ -f rsl.out.0000 ]]; then
      rm -rf $RUN_DIR/rsl
      mkdir -p $RUN_DIR/rsl
      mv rsl* $RUN_DIR/rsl
      cd $RUN_DIR/rsl
      for FILE in rsl*; do
         echo "<HTML><HEAD><TITLE>$FILE</TITLE></HEAD>" > $FILE.html
         echo "<H1>$FILE</H1><PRE>" >> $FILE.html
         cat $FILE >> $FILE.html
         echo "</PRE></BODY></HTML>" >> $FILE.html
#         rm $FILE
      done
      echo '<A HREF="rsl_'${WRF_CONF}'/rsl.out.0000.html">rsl.out.0000</a>'
      echo '<A HREF="rsl_'${WRF_CONF}'/rsl.error.0000.html">rsl.error.0000</a>'
      echo '<A HREF="rsl_'${WRF_CONF}'>Other RSL output</a>'
   fi

   echo $(date +'%D %T') "Ended $RC"


if [[ $WRF_CONF == "" ]]; then
   mv $WORK_DIR/wrfinput_* $FC_DIR_DATE
   mv $WORK_DIR/wrfout_*   $FC_DIR_DATE
   mv $WORK_DIR/wrfvar_input_* $FC_DIR_DATE
fi

if $CLEAN; then
   rm -rf $WORK_DIR
fi

date

echo "</BODY></HTML>"

exit $RC

