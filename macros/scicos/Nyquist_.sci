function Nyquist_()
  syst=analyse(scs_m)
  %sl=bloc2ss(syst)
  xset('window',curwin+1);xclear();// XX xbasc()
  nyquist( %sl)
  xset('window',curwin);
endfunction
