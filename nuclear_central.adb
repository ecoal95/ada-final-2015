with Ada.Text_IO;

package body Nuclear_Central is
  protected body Nuclear_Central is
    procedure Monitoring_Alert_Callback(event: in out Timing_Event) is
    begin
      Ada.Text_IO.Put_Line("ALERTA MONITORIZACIÓN DE ENERGÍA");
    end Monitoring_Alert_Callback;

    procedure Reset_Monitoring_Callback is
    begin
      Set_Handler(Monitoring_Event,
                  MONITORING_ALERT_INTERVAL,
                  Monitoring_Alert_Callback'Access);
    end Reset_Monitoring_Callback;

    procedure Increment_Callback(event: in out Timing_Event) is
    begin
      current_production := current_production + 1;
      increment_pending := false;
    end Increment_Callback;

    procedure Decrement_Callback(event: in out Timing_Event) is
    begin
      current_production := current_production - 1;
      decrement_pending := false;
    end Decrement_Callback;

    entry start
    when started = false is
    begin
      Reset_Monitoring_Callback;
      started := true;
    end start;

    entry read_value(value: out Integer)
    when started is
    begin
      -- Artificial delay required by the statement
      delay SENSOR_JITTER;
      value := current_production;
    end read_value;

    entry increment
    when started and current_production < MAX_PRODUCTION is
      cancelled: Boolean;
    begin
      Reset_Monitoring_Callback;
      if increment_pending = false then
        if decrement_pending then
          Cancel_Handler(Decrement_Event, cancelled);
          if cancelled = false then
            Ada.Text_IO.Put_Line("Decrement cancellation failed, decrement aborted");
            return;
          end if;
          decrement_pending := false;
        end if;

        -- Artificial delay required
        delay CONTROL_JITTER;

        Set_Handler(Increment_Event,
                    VALUE_CHANGE_DURATION,
                    Increment_Callback'Access);
        increment_pending := true;
      end if;
    end increment;

    entry decrement
    when started and current_production > MIN_PRODUCTION is
      cancelled: Boolean;
    begin
      Reset_Monitoring_Callback;
      if decrement_pending = false then
        if increment_pending then
          Cancel_Handler(Increment_Event, cancelled);
          if cancelled = false then
            Ada.Text_IO.Put_Line("Increment cancellation failed, decrement aborted");
            return;
          end if;
          increment_pending := false;
        end if;

        -- Artificial delay required
        delay CONTROL_JITTER;

        Set_Handler(Decrement_Event,
                    VALUE_CHANGE_DURATION,
                    Decrement_Callback'Access);
        decrement_pending := true;
      end if;
    end decrement;

    entry maintain
    when started is
      cancelled: Boolean;
    begin
      Reset_Monitoring_Callback;

      if decrement_pending then
        Cancel_Handler(Decrement_Event, cancelled);
        if cancelled = false then
          Ada.Text_IO.Put_Line("Decrement cancellation failed");
          return;
        end if;
        decrement_pending := false;
      end if;

      if increment_pending then
        Cancel_Handler(Increment_Event, cancelled);
        if cancelled = false then
          Ada.Text_IO.Put_Line("Increment cancellation failed");
          return;
        end if;
        increment_pending := false;
      end if;
    end maintain;
  end Nuclear_Central;
end Nuclear_Central;
