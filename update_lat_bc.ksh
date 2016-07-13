# update lateral bdy for coarse domain
#if ( ${DOMAIN_ID} == '01' ) then
#   cd ${DA_RUNDIR}
   cp -p ${RC_DIR}/${INITIAL_DATE}/wrfbdy_d${DOMAIN} ${WORK_DIR}/wrfbdy_d${DOMAIN}
   cat > ${WORK_DIR}/parame.in << EOF
&control_param
 da_file            = '${WORK_DIR}/wrfvar_output'
 wrf_bdy_file       = '${WORK_DIR}/wrfbdy_d${DOMAIN}'
 wrf_input          = '${RC_DIR}/${INITIAL_DATE}/wrfinput_d${DOMAIN}'
 domain_id          = ${DOMAIN}
 debug              = .false.
 update_lateral_bdy = .true.
 update_low_bdy     = .false
 update_lsm         = .false.
 iswater            = 17 /
EOF
   ln -sf ${BUILD_DIR}/da_update_bc.exe .
   time ./da_update_bc.exe > update_lat_bc_${DATE}.log
   mv parame.in $RUN_DIR/parame.in.latbdy
   # check status
   grep "Update_bc completed successfully" update_lat_bc_${DATE}.log
#   if ( $status != 0 ) then
#      echo "ERROR in run_wrfda.csh : update lateral bdy failed..."
#      exit 1
#   endif
#endif 
exit $?
