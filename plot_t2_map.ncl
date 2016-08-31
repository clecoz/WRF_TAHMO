load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"

begin

; Make a list of all files we are interested in
  DATADir = "/home/camille/DATA/volta/test48/fc/2016080100/"
  FILES = systemfunc (" ls -1 " + DATADir + "wrfout_d01* ")
  numFILES = dimsizes(FILES)
  print("numFILES = " + numFILES)
  print(FILES)
  print (" ")

; We generate plots, but what kind do we prefer?
;  type = "x11"
  type = "pdf"
; type = "ps"
; type = "ncgm"
  wks = gsn_open_wks(type,"plt_t2_map")

  a = addfiles(FILES+".nc","r");  
  t2 = wrf_user_getvar(a,"T2",-1);


  times_in_file = wrf_user_getvar(a,"Times",-1);
  dims = dimsizes(times_in_file)
  ntimes=dims(0)
  times = new(dims(0),string)
  do i=0,dims(0)-1
    times(i) = chartostring(times_in_file(i,8:12))
  end do

;------------------------------------------------------------------------

lat=(/5.4468564, 6.664616, 5.5730222/)
lon=(/-2.1339285, -3.097246, -0.24447074/)

;------------------------------------------------------------------------
res = True                            ; Set basic resources both will use
res@gsnFrame                    = False 
res@gsnDraw         = False           ; Don't draw individual plot

do it = 0,ntimes-1,2             ; TIME LOOP

    print("Working on time: " + times(it) )
    res@TimeLabel = times(it)   ; Set Valid time to use on plots

 

;  res = True                            ; Set basic resources both will use
  res@cnFillOn = True                        ; Create a color fill plot
  res@cnLevelSelectionMode = "ExplicitLevels"
  res@cnLevels = ispan(288,318,2)
  contour = wrf_contour(a[it],wks,t2(it,:,:),res)


  pltres = True                              ; Set plot options
  mpres = True                               ; Set map options
  plot = wrf_map_overlays(a[it],wks,(/contour/),pltres,mpres)  ; Plot the data over a map background

  mkres               = True
  mkres@gsMarkerIndex = 17     ; Filled circle
  mkres@gsMarkerSizeF = 0.03
  marker=gsn_add_polymarker(wks,plot,lon,lat,mkres)

;  draw(plot)
;  frame(wks)                            ; now frame the plot   

 end do        ; END OF TIME LOOP


end
