load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
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
  t2 = wrf_user_getvar(a,"T2",-1);


  lat2d = wrf_user_getvar(a,"XLAT",0);
  lon2d = wrf_user_getvar(a,"XLONG",0)
  lat = (/ 5.8112918 /)
  lon = (/ -2.8256169 /)
  nm = getind_latlon2d (lat2d,lon2d, lat, lon)

;  t2_point = t2(:,nm(0,0),nm(0,1));
  t2_point = t2(:,150,77);


  times_in_file = wrf_user_getvar(a,"Times",-1);
  dims = dimsizes(times_in_file)
  times = new(dims(0),string)
  do i=0,dims(0)-1
    times(i) = chartostring(times_in_file(i,8:12))
  end do
  
  taus = (/ 1., 2., 3., 4., 5., 6., 7., 8., 9., 10., 11., 12., 13., 14., 15., 16., 17., 18., 19., 20., 21., 22., 23., 24. , 25., 26., 27., 28., 29., 30., 31., 32., 33., 34., 35., 36., 37., 38., 39., 40., 41., 42., 43., 44., 45., 46., 47., 48. /)       ; create a time reference
;  taus = (/ 0., 6., 12., 18., 24., 30., 36., 42. /)       ; create a time reference

;taus = (/ 1., 2., 3., 4., 5., 6., 7., 8., 9., 10., 11., 12., 13., 14., 15., 16., 17., 18., 19., 20., 21., 22., 23., 24./)     

;-----------------------------------------------------------------------

data = readAsciiTable("/home/camille/DATA/volta/test48/wrf/working/4.d01.TS", 19, "float", 1)   ; read the data file
print(data(0,3))
print(data(0,4))
print(nm)

; t2_point = t2(:,data(0,4),data(0,3));

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
  res@trYMinF = min(t2_point-273.15)
  res@trYMaxF = max(t2_point-273.15)
  

  tsl_res = res
;  tsl_res@vpYF            = 0.75        ; The top side of the plot box loc
  tsl_res@xyLineColor    =  "red"       ; set line color
  tsl_res@tmXTOn         = False        
  tsl_res@xyLineThicknesses = 2        
;  tsl_res@xyLineColor    =  "blue"    
  tsl_res@tiYAxisString = "2m Temperature"
  tsl_res@tiXAxisString = "Simulation Time"
  tsl_res@tiMainString = "12Z 24 Jan 2000"

  t2_res = res
;  t2_res@vpYF            = 0.45         ; The top side of the plot box loc
  t2_res@xyLineColor    =  "blue"       ; set line color


;  t2_plot  = gsn_csm_xy(wks,taus,tmn_point-273.15,t2_res)
;  t2_plot  = gsn_csm_y(wks,t2_point,t2_res)
;  tsl_plot  = gsn_csm_xy(wks,data(:,1),data(:,5),tsl_res)    ; we know column 2 is time and column 6 is T2
;  draw(tsl_plot) 
;  draw(t2_plot) 

  plot = gsn_csm_x2y2(wks,data(:,1),taus,data(:,5)-273.15,t2_point-273.15,tsl_res,t2_res)
  draw(plot)

  frame(wks)                            ; now frame the plot   

end
