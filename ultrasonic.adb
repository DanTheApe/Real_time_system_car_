-- AI Hevaly used for help here

with Ada.Real_Time;           use Ada.Real_Time;
with MicroBit.TimeHighspeed;  use MicroBit.TimeHighspeed;

package body Ultrasonic is

   Start_Timeout : constant Time_Span := Milliseconds (3);

   End_Timeout : constant Time_Span := Milliseconds (23);

   Trigger : GPIO_Point := Trigger_Pin;
   Echo    : GPIO_Point := Echo_Pin;

   function Read return Distance_cm is
      Count    : Distance_cm := 0;
      Deadline : Time;
   begin

      if Echo.Set then
         return 0;
      end if;

      Trigger.Set;
      Delay_Us (10);
      Trigger.Clear;

      Deadline := Clock + Start_Timeout;
      while not Echo.Set loop
         if Clock >= Deadline then
            return 0;
         end if;
      end loop;

      Deadline := Clock + End_Timeout;
      while Echo.Set loop
         if Clock >= Deadline or else Count = Distance_cm'Last then
            return 0;
         end if;
         Delay_Us (58);
         Count := Count + 1;
      end loop;

      return Count;
   end Read;

begin
   declare
      Conf : GPIO_Configuration;
   begin
      Conf.Mode         := Mode_Out;
      Conf.Resistors    := No_Pull;
      Conf.Input_Buffer := Input_Buffer_Connect;
      Conf.Sense        := Sense_Disabled;
      Trigger.Configure_IO (Conf);
      Trigger.Clear;

      Conf.Mode := Mode_In;
      Echo.Configure_IO (Conf);
   end;
end Ultrasonic;
