with Ada.Real_Time; use Ada.Real_Time;
with Ada.Real_Time.Timing_Events; use Ada.Real_Time.Timing_Events;

package Nuclear_Central is
  SENSOR_JITTER: constant Duration := To_Duration(Milliseconds(50));
  CONTROL_JITTER: constant Duration := To_Duration(Milliseconds(100));
  MAX_PRODUCTION: constant Integer := 30;
  MIN_PRODUCTION: constant Integer := 0;
  MONITORING_ALERT_INTERVAL: constant Time_Span := Seconds(2);
  VALUE_CHANGE_DURATION: constant Time_Span := Seconds(1);

  protected type Nuclear_Central is
    entry read_value(value: out Integer);
    entry increment;
    entry decrement;
    entry maintain;
    entry start;
  private
    current_production: Integer := 15;
    increment_pending: Boolean := false;
    decrement_pending: Boolean := false;
    started: Boolean := false;
    Increment_Event: Timing_Event;
    Decrement_Event: Timing_Event;
    Monitoring_Event: Timing_Event;
  end Nuclear_Central;
end Nuclear_Central;
