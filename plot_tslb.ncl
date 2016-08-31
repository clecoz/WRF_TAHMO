load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"

begin

; Make a list of all files we are interested in
  DATADir = "/home/camille/DATA/volta/test48/fc/2016080100/"
  FILES = systemfunc (" ls -1 " + DATADir + "wrfout_d01* ")
  numFILES = dimsizes(FILES)

; We generate plots, but what kind do we prefer?
  type = "x11"
; type = "pdf"
; type = "ps"
; type = "ncgm"
  wks = gsn_open_wks(type,"plt_tslb")

  a = addfiles(FILES+".nc","r");  
  tslb = wrf_user_getvar(a,"TSLB",-1);
  tmn = wrf_user_getvar(a,"T2",-1);


  lat2d = wrf_user_getvar(a,"XLAT",0);
  lon2d = wrf_user_getvar(a,"XLONG",0)
  lat = (/ 5.4468564 /)
  lon = (/ -2.1339285 /)
  nm = getind_latlon2d (lat2d,lon2d, lat, lon)
;print(nm)
;print(lat2d(nm(0,0),nm(0,1)))

  tslb_point = tslb(:,0,nm(0,0),nm(0,1));
  tmn_point = tmn(:,nm(0,0),nm(0,1));

;print(dimsizes(tslb))
print(getvardims(tslb))
;print(dimsizes(lat2d))
;print(getvardims(lat2d))

  
  times_in_file = wrf_user_getvar(a,"Times",-1);
  dims = dimsizes(times_in_file)
  times = new(dims(0),string)
  do i=0,dims(0)-1
    times(i) = chartostring(times_in_file(i,8:12))
  end do
  
;  taus = (/ 1., 2., 3., 4., 5., 6., 7., 8., 9., 10., 11., 12., 13., 14., 15., 16., 17., 18., 19., 20., 21., 22., 23., 24. /)       ; create a time reference
  taus = (/ 0., 6., 12., 18., 24., 30., 36., 42. /)       ; create a time reference


;-----------------------------------------------------------------------

  res = True                            ; Set basic resources both will use
  res@vpXF            = 0.15            ; The left side of the box location
  res@vpWidthF        = 0.70            ; The Width of the plot box
  res@vpHeightF       = 0.20            ; The height of the plot box
  res@tmXBMode       = "Explicit"       ; Define own tick mark labels.
  res@tmXBValues     = taus             ; location of explicit labels
  res@tmXBLabels     = times            ; labels are the locations
  res@tmXTOn         = False            ; turn off the top tick marks
  res@xyLineThicknesses = 2             ; increase line thickness
  res@gsnDraw         = False           ; Don't draw individual plot.
  res@gsnFrame        = False           ; Don't advance frame.
  

  tslb_res = res
  tslb_res@vpYF            = 0.75        ; The top side of the plot box loc
  tslb_res@xyLineColor    =  "red"       ; set line color

  tmn_res = res
  tmn_res@vpYF            = 0.45         ; The top side of the plot box loc
  tmn_res@xyLineColor    =  "blue"       ; set line color

;  tslb_plot  = gsn_csm_xy(wks,taus,tslb_point-273.15,tslb_res)
  tslb_plot  = gsn_csm_y(wks,tslb_point-273.15,tslb_res)
;  tmn_plot  = gsn_csm_xy(wks,taus,tmn_point-273.15,tmn_res)
  tmn_plot  = gsn_csm_y(wks,tmn_point-273.15,tmn_res)
  draw(tslb_plot) 
  draw(tmn_plot) 

  frame(wks)                            ; now frame the plot   

end
