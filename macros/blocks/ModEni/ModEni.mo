package Hydraulics
  //inner Real test;
  model Medias
  public
    parameter Real rho=1000;
    parameter Real nu=1.007e-6;
    parameter Real qmin=1.0e-6;
    parameter Real g=9.8;
    parameter Real p0=1.013e5;
    constant Real pi=3.14159;
  end Medias;

  model Pression
    inner Real test1;
    parameter Real test=0.0;
  equation
    test1=test;
  end Pression;
  
  model Ground "Ground, fix pressure"
    Pin p;
  equation
    p.pression = 0;
  end Ground;

  model Reservoir "tout d'abord, on définit un réservoir où le fluide entre dedans"
    Pin p;
    extends Info;
    extends Medias;
    parameter Real initialHt = 0.0 "inital water level in the tank[m]";
    parameter Real Area = 1.0 "[m]";
    parameter Real inHt = 0.0;
    Real Ht(start = initialHt);
    Real pvessel;
    constant Real kcon = 0.5;
    Real dp_outflow;
  equation
    der(Ht) = p.q / Area;
    pvessel = noEvent(if inHt > Ht then 0 + p0 else rho * g * (Ht - inHt)+ p0);
    dp_outflow=(rho / 2) / Area * (1 + kcon) * p.q^2;
    p.pression = noEvent(if p.q >= 0 then pvessel else pvessel - dp_outflow);
  end Reservoir;

  connector Pin
    Real pression "[Pa] pressure";
    flow Real q "[m^3/s] volumetric flow";
  end Pin;

  partial model TwoPin
    Pin p,n;
    Real q,dpression;
  equation
    q = p.q;
    n.q = -q;
    dpression = p.pression - n.pression;
  end TwoPin;

  model Info
    parameter Real price "le prix du composant [€]";
    parameter Real mass "la masse du composant [kg]";
    parameter Real LeadTime;
  end Info;

  model Atmosphere
    Pin p;
    extends Medias;
  equation
    p.pression = p0;//+p.q/1e6;
  end Atmosphere;

  model Tuyau 
    extends TwoPin;
    extends Info;
    extends Medias;
    parameter Real L=1.0;
    parameter Real D=0.5;
    parameter Real A=pi/4*D^2;
    parameter Real vRe2300=2300*nu/D;
    parameter Real vRe4000=4000*nu/D;
    parameter Real klam=0.32*D^(-2)*nu*L*rho;
    parameter Real k1trans=(1/(vRe4000/vRe2300 - 1))*(kturb*vRe4000^(7/4) - klam*vRe4000);
    parameter Real k2trans=(1/vRe2300)*(klam*vRe2300 + k1trans);
    parameter Real kturb=0.182*D^(-5/4)*nu^(1/4)*L*rho;
    Real v;//(start=1.0, fixed=false) "flow velocity";
  equation 
    v = q/A;
    //pressure drop relation
    dpression =noEvent( if (v > -vRe2300) and (v < vRe2300) then klam*v else if (v >= vRe2300) and (v< vRe4000) then -k1trans + k2trans*v else if (v <= -vRe2300) and (v > -vRe4000) then k1trans + k2trans*v else kturb*sign(v)*noEvent(abs(v))^(7/4));
    //dpression=klam*v;
    //dpression=kturb*sign(v)*noEvent(abs(v))^(7/4);
  end Tuyau;


  model PressureSensor
    extends Info;    
    extends TwoPin;
    extends Medias;
    parameter Real IsPa=1;
    Real dpression_conv;
  equation
    q = 0.0;
    dpression_conv =noEvent( if IsPa>0 then dpression else dpression/p0);
  end PressureSensor;

  model FluxSensor
    extends Info;
    extends TwoPin;
  equation
    dpression = 0.0;
  end FluxSensor;

  package Constants "water fluid constants"
    constant Real rho = 1000 "[kg/m^3] water density";
    constant Real nu = 1.002e-006 "[m^2/s] water kinematic viscosity";
    constant Real qmin = 1e-6 "[m^3/s] minimum volumetric flow";
    constant Real g = 9.8 "[m/s^2]";
    constant Real p0=101350 "kg/s^2/m the atmosphere pressure";
  end Constants;

  model ValveDiscrete
    extends TwoPin;
    extends Info;
    parameter Real sthreshold = 1.0 "le signal qui décide la fermeture de la vanne";
    Real signal;
    parameter Real checkvalve=0.0 "if ==";
  equation
    if signal > sthreshold then
      dpression = 0.0;
    else
      //q = noEvent(if q>0 then 0.0 else 1e-6);
      q=0.0;
    end if;
  end ValveDiscrete;

  model CheckValve
    extends TwoPin;
    extends Info;
    parameter Real Ids=1.e-6 "Saturation current";
    parameter Real Vt=0.04   "Voltage equivalent of temperature (kT/qn)";
    parameter Real Maxexp=15 "Max. exponent for linear continuation";
    parameter Real R=1.e8 "Parallel ohmic resistance";
  equation 
    q = if noEvent(dpression/Vt > Maxexp) then 
        Ids*(exp(Maxexp)*(1 + dpression/Vt - Maxexp) - 1) + dpression/R
      else 
        Ids*(exp(dpression/Vt) - 1) + dpression/R;
  end CheckValve;

  model Diode "Simple diode" 
    extends TwoPin;
    parameter Real Ids=1.e-6 "Saturation current";
    parameter Real Vt=0.04   "Voltage equivalent of temperature (kT/qn)";
    parameter Real Maxexp=15 "Max. exponent for linear continuation";
    parameter Real R=1.e8 "Parallel ohmic resistance";
  equation 
    i = if noEvent(v/Vt > Maxexp) then 
      Ids*(exp(Maxexp)*(1 + v/Vt - Maxexp) - 1) + v/R 
      else 
      Ids*(exp(v/Vt) - 1) + v/R;
  end Diode;

  model ValveContinuous
    extends TwoPin;
    extends Info;
    parameter Real kvs = 1.0;
    Real x;
    Real kx;
    //la position de la vanne
    Real kv;
    constant Real xmin=1e-4;
  equation
    kx= noEvent(if x<=kvs then x else kvs);
    kv=noEvent(if kx>xmin then kvs*kx else kvs*xmin);
    dpression=noEvent(if q>0 then (1/kv^2)*q^2*1000 else -(1/kv^2)*q^2*1000);
    //valve characteristic, prevent y to become zero, valve leakes always a little
    //in that the valve travel stops at xmin
  end ValveContinuous;
  //à développer

  model Tank2
    Pin p;
    Pin n;
    extends Info;
    extends Medias;
    parameter Real initialHt=0.0;
    parameter Real Area=1.0;
    parameter Real inHt1=0.0;
    parameter Real inHt2=0.0;
    Real Ht(start=initialHt);
    Real pvessel1;
    Real pvessel2;
    //constant Real rho = Aeraulics.Constants.rho;
    //constant Real g = Aeraulics.Constants.g;
    constant Real kcon1 = 0.5;
    constant Real kcon2 = 0.5;
  equation
    der(Ht)=(p.q+n.q)/Area;
    pvessel1 = if inHt1 > Ht then 0+p0 else rho * g * (Ht - inHt1)+p0;
    pvessel2 = if inHt2 > Ht then 0+p0 else rho * g * (Ht - inHt2)+p0;
    p.pression = noEvent(if p.q > 0 then pvessel1 else pvessel1 - (rho / 2 * 1) / Area * (1 + kcon1) * p.q * p.q);
    n.pression = noEvent(if n.q > 0 then pvessel2 else pvessel2 - (rho / 2 * 1) / Area * (1 + kcon2) * n.q * n.q);
  end Tank2;

  model Tank3
    Pin p;
    Pin n;
    Pin t;
    extends Info;
    extends Medias;
    parameter Real initialHt=0.0;
    parameter Real Area=1.0;
    parameter Real inHt1=0.0;
    parameter Real inHt2=0.0;
    parameter Real inHt3=0.0;
    Real Ht(start=initialHt);
    Real pvessel1;
    Real pvessel2;
    Real pvessel3;
    //constant Real rho = Aeraulics.Constants.rho;
    //constant Real g = Aeraulics.Constants.g;
    constant Real kcon1 = 0.5;
    constant Real kcon2 = 0.5;
    constant Real kcon3 = 0.5;
  equation
    der(Ht)=(p.q+n.q+t.q)/Area;
    pvessel1 = if inHt1 > Ht then 0+p0 else rho * g * (Ht - inHt1)+p0;
    pvessel2 = if inHt2 > Ht then 0+p0 else rho * g * (Ht - inHt2)+p0;
    pvessel3 = if inHt3 > Ht then 0+p0 else rho * g * (Ht - inHt3)+p0;
    p.pression = noEvent(if p.q > 0 then pvessel1 else pvessel1 - (rho / 2 * 1) / Area * (1 + kcon1) * p.q * p.q);
    n.pression = noEvent(if n.q > 0 then pvessel2 else pvessel2 - (rho / 2 * 1) / Area * (1 + kcon2) * n.q * n.q);
    t.pression = noEvent(if t.q > 0 then pvessel3 else pvessel3 - (rho / 2 * 1) / Area * (1 + kcon3) * t.q * t.q);
  end Tank3;

  model PressionSource
    extends TwoPin;
    extends Info;
    extends Medias;
    parameter Real userp = p0 "[Pa]";
    parameter Real IsPa=1;
  equation
    dpression =noEvent(if IsPa>0 then userp else userp*p0);
  end PressionSource;

  model VolumeFlow
    extends TwoPin;
    extends Medias;
    extends Info;
    Real userq ;// = 1.0 "[m^3/s]";
  equation
  // q est le debit en p.q
  // avec ce test l'intégrateur se bloque 
  // q = noEvent(if p.pression <= p0*(1+0.001) then 0.1 else userq );
  q = userq;
  end VolumeFlow;

end Hydraulics;

model HydroMedias
  extends Hydraulics.Medias;
end HydroMedias;

model HydroPressionSource
  extends Hydraulics.PressionSource;
end HydroPressionSource;

model HydroVolumeFlow
  extends Hydraulics.VolumeFlow;
end HydroVolumeFlow;

model HydroAtmosphere
  extends Hydraulics.Atmosphere;
end HydroAtmosphere;

model HydroGround
  extends Hydraulics.Ground;
end HydroGround;

model HydroPression
  extends Hydraulics.Pression;
end HydroPression;

model HydroReservoir
  extends Hydraulics.Reservoir;
end HydroReservoir;

model HydroTank2
  extends Hydraulics.Tank2;
end HydroTank2;

model HydroTank3
  extends Hydraulics.Tank3;
end HydroTank3;

model HydroTuyau
  extends Hydraulics.Tuyau;
end HydroTuyau;
model HydroFluxSensor
  extends Hydraulics.FluxSensor;
end HydroFluxSensor;

model HydroPressureSensor
  extends Hydraulics.PressureSensor;
end HydroPressureSensor;

model HydroCheckValve
  extends Hydraulics.CheckValve;
end HydroCheckValve;
model HydroValveContinuous
  extends Hydraulics.ValveContinuous;
end HydroValveContinuous;

model HydroValveDiscrete
  extends Hydraulics.ValveDiscrete;
end HydroValveDiscrete;

