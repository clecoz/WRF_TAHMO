
#cat >! ${WORK_DIR}/parame.in << EOF
cat > ${WORK_DIR}/parame.in << EOF
&control_param
 da_file            = '${WORK_DIR}/fg'
 wrf_input          = '${RC_DIR}/${INITIAL_DATE}/wrfinput_d${DOMAIN}'
 domain_id          = ${DOMAIN}
 debug              = .false.
 update_lateral_bdy = .false.
 update_low_bdy     = .true.
 update_lsm         = .false.
 iswater            = 17 /
EOF
#ln -fs ${BUILD_DIR}/var/build/da_update_bc.exe .
ln -fs ${BUILD_DIR}/da_update_bc.exe .
#time ./da_update_bc.exe >&! update_low_bc_${DATE}.log
time ./da_update_bc.exe > update_low_bc_${DATE}.log
mv parame.in $RUN_DIR/parame.in.lowbdy
# check status
grep -i "Update_bc completed successfully" update_low_bc_${DATE}.log
#if ( $status != 0 ) then
#   echo "ERROR in run_wrfvar2.ksh : update low bdy failed..."
#   exit 1
#endif 
exit $?
