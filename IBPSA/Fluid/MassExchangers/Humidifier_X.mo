within IBPSA.Fluid.MassExchangers;
model Humidifier_X
  "Adiabatic humidifier (or dehumidifier) with leaving water mass fraction as input"
  extends IBPSA.Fluid.Interfaces.PartialTwoPortInterface;
  extends IBPSA.Fluid.Interfaces.TwoPortFlowResistanceParameters(
    final computeFlowResistance=(abs(dp_nominal) > Modelica.Constants.eps));
  extends IBPSA.Fluid.Interfaces.PrescribedOutletParameters(
    redeclare final package _Medium = Medium,
    final T_start=293.15,
    X_start=Medium.X_default,
    final use_TSet = false,
    final use_X_wSet = true,
    final QMax_flow = 0,
    final QMin_flow = 0,
    final mWatMin_flow = 0,
    final energyDynamics = Modelica.Fluid.Types.Dynamics.DynamicFreeInitial,
    massDynamics = Modelica.Fluid.Types.Dynamics.SteadyState);

  parameter Boolean homotopyInitialization = true "= true, use homotopy method"
    annotation(Evaluate=true, Dialog(tab="Advanced"));

  // Set maximum to a high value to avoid users mistakenly entering relative humidity.
  Modelica.Blocks.Interfaces.RealInput X_w(unit="1", min=0, max=0.03)
    "Set point for water vapor mass fraction in kg/kg total air of the fluid that leaves port_b"
    annotation (Placement(transformation(extent={{-140,40},{-100,80}})));

  Modelica.Blocks.Interfaces.RealOutput mWat_flow(unit="kg/s")
    "Water added to the fluid (if flow is from port_a to port_b)"
    annotation (Placement(transformation(extent={{100,50},{120,70}})));

protected
  IBPSA.Fluid.FixedResistances.PressureDrop preDro(
    redeclare final package Medium = Medium,
    final m_flow_nominal=m_flow_nominal,
    final deltaM=deltaM,
    final allowFlowReversal=allowFlowReversal,
    final show_T=false,
    final from_dp=from_dp,
    final linearized=linearizeFlowResistance,
    final homotopyInitialization=homotopyInitialization,
    final dp_nominal=dp_nominal) "Flow resistance"
    annotation (Placement(transformation(extent={{-50,-10},{-30,10}})));

  IBPSA.Fluid.Interfaces.PrescribedOutlet hum(
    redeclare final package Medium = Medium,
    final allowFlowReversal=allowFlowReversal,
    final m_flow_small=m_flow_small,
    final show_T=false,
    final mWatMax_flow=mWatMax_flow,
    final m_flow_nominal=m_flow_nominal,
    final tau=tau,
    final X_start=X_start,
    final energyDynamics=energyDynamics,
    final massDynamics=massDynamics,
    final use_TSet=false,
    final mWatMin_flow=0) "Humidifier"
    annotation (Placement(transformation(extent={{20,-10},{40,10}})));
equation
  connect(port_a, preDro.port_a) annotation (Line(
      points={{-100,0},{-50,0}},
      color={0,127,255}));
  connect(preDro.port_b, hum.port_a)
    annotation (Line(points={{-30,0},{20,0}}, color={0,127,255}));
  connect(hum.port_b, port_b)
    annotation (Line(points={{40,0},{100,0}}, color={0,127,255}));
  connect(hum.mWat_flow, mWat_flow) annotation (Line(points={{41,4},{80,4},{80,60},
          {110,60}}, color={0,0,127}));
  connect(X_w, hum.X_wSet) annotation (Line(points={{-120,60},{-72,60},{0,60},{0,
          4},{18,4}}, color={0,0,127}));
  annotation (Icon(coordinateSystem(preserveAspectRatio=false, extent={{-100,
            -100},{100,100}}), graphics={
        Rectangle(
          extent={{-102,5},{99,-5}},
          lineColor={0,0,255},
          pattern=LinePattern.None,
          fillColor={0,0,0},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{-100,60},{-70,58}},
          lineColor={0,0,255},
          pattern=LinePattern.None,
          fillColor={0,0,127},
          fillPattern=FillPattern.Solid),
        Text(
          extent={{-106,104},{-62,76}},
          lineColor={0,0,127},
          textString="X_w"),
        Rectangle(
          extent={{60,60},{100,58}},
          lineColor={0,0,255},
          pattern=LinePattern.None,
          fillColor={0,0,127},
          fillPattern=FillPattern.Solid),
        Text(
          extent={{34,118},{100,64}},
          lineColor={0,0,127},
          textString="mWat_flow"),
        Rectangle(
          extent={{-70,80},{70,-80}},
          lineColor={0,0,255},
          pattern=LinePattern.None,
          fillColor={85,170,255},
          fillPattern=FillPattern.Solid)}),
defaultComponentName="hea",
Documentation(info="<html>
<p>
Model for an adiabatic humidifier with a prescribed outlet water vapor mass fraction
in kg/kg total air.
</p>
<p>
This model forces the outlet water mass fraction at <code>port_b</code> to be
not lower than the
input signal <code>X_wSet</code>, subject to optional limits on the
maximum water vapor mass flow rate that is added, as
described by the parameters
<code>mWatMax_flow</code>.
By default, the model has unlimited capacity.
</p>
<p>
The output signal <code>mWat_flow</code> is the moisture added
to the medium if the flow rate is from <code>port_a</code> to <code>port_b</code>.
If the flow is reversed, then <code>mWat_flow=0</code>.
</p>
<p>
The outlet conditions at <code>port_a</code> are not affected by this model.
</p>
<p>
If the parameter <code>energyDynamics</code> is not equal to
<code>Modelica.Fluid.Types.Dynamics.SteadyState</code>,
the component models the dynamic response using a first order differential equation.
The time constant of the component is equal to the parameter <code>tau</code>.
This time constant is adjusted based on the mass flow rate using
</p>
<p align=\"center\" style=\"font-style:italic;\">
&tau;<sub>eff</sub> = &tau; |m&#775;| &frasl; m&#775;<sub>nom</sub>
</p>
<p>
where
<i>&tau;<sub>eff</sub></i> is the effective time constant for the given mass flow rate
<i>m&#775;</i> and
<i>&tau;</i> is the time constant at the nominal mass flow rate
<i>m&#775;<sub>nom</sub></i>.
This type of dynamics is equal to the dynamics that a completely mixed
control volume would have.
</p>
<p>
Optionally, this model can have a flow resistance.
If no flow resistance is requested, set <code>dp_nominal=0</code>.
</p>
<p>
For a model that uses a control signal <i>u &isin; [0, 1]</i> and multiplies
this with the nominal water mass flow rate, use
<a href=\"modelica://IBPSA.Fluid.MassExchangers.Humidifier_u\">
IBPSA.Fluid.MassExchangers.Humidifier_u</a>

</p>
<h4>Limitations</h4>
<p>
This model only adds water vapor for the flow from
<code>port_a</code> to <code>port_b</code>.
The water vapor of the reverse flow is not affected by this model.
</p>
<p>
This model does not affect the enthalpy of the air. Therefore,
if water is added, the temperature will decrease, e.g., the humidification
is adiabatic.
</p>
</html>",
revisions="<html>
<ul>
<li>
May 3, 2017, by Michael Wetter:<br/>
First implementation.
</li>
</ul>
</html>"));
end Humidifier_X;
