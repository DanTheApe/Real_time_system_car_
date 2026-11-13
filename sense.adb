with Ada.Execution_Time; use type Ada.Execution_Time.CPU_Time;
with MicroBit.Console; use MicroBit.Console;
with Ultrasonic;

package body Sense is
   package Front_Sensor is new Ultrasonic (Trigger_Pin => Front_Trigger, Echo_Pin => Front_Echo);
   package Back_Sensor is new Ultrasonic (Trigger_Pin => Back_Trigger, Echo_Pin => Back_Echo);
   package Left_Sensor is new Ultrasonic (Trigger_Pin => Left_Trigger, Echo_Pin => Left_Echo);
   package Right_Sensor is new Ultrasonic (Trigger_Pin => Right_Trigger, Echo_Pin => Right_Echo);

   function Read (S : Side) return Distance_cm is
     (case S is
         when Front => Front_Sensor.Read,
         when Back => Back_Sensor.Read,
         when Left => Left_Sensor.Read,
         when Right => Right_Sensor.Read);

   function Clean (D : Distance_cm) return Distance_cm is (if D < 2 then Nothing_Seen else D);
   -- Tidlig hadde vi ikke 4 sensorer so lagde denne
   function Shown (S : Side; Scan : Distances) return String is
     (if not Installed (S) then " --"
      elsif Scan (S) = Nothing_Seen then " nothing"
      else Scan (S)'Image & " cm");

   task body Scanner is
      Next : Time := Clock;
      Scan : Distances;
      Start : Ada.Execution_Time.CPU_Time;
      Took : Time_Span;
      Inter : Time_Span;
      Real_Start : Time;
      Real_Took  : Time_Span;
      Real_Inter : Time_Span;
      Read_Start : Time;
      Late : Time_Span;
      Job : Natural := 0;
   begin
      loop
       -- Mye timing greier her. ville se hvor mye tid per sensor sov.
         -- Start := Ada.Execution_Time.Clock;
         -- Real_Start := Ada.Real_Time.Clock;
         -- Late := Real_Start - Next;
         -- Job := Job + 1;

         for S in Side loop
            if Installed (S) then
               -- Read_Start := Ada.Real_Time.Clock;

               Scan (S) := Clean (Read (S));

               -- Real_Inter := Ada.Real_Time.Clock - Read_Start;
               -- Inter := Ada.Execution_Time.Clock - Start;
               -- Put_Line ("Scan: " & Integer'Image (Inter / Microseconds (1)) & " us");
               -- Put_Line ("Read: " & S'Image & ":" & Shown (S, Scan) & " tok " & Integer'Image (Real_Inter / Microseconds (1)) & " us");

               delay until Clock + Waiter;
            else
               Scan (S) := Nothing_Seen;
            end if;
         end loop;

         Latest.Update (Scan);


         -- Put_Line ("Front: " & Shown (Front, Scan) & "  Back: " & Shown (Back, Scan) & "  Left: " & Shown (Left, Scan) & "  Right: " & Shown (Right, Scan));


         -- Took := Ada.Execution_Time.Clock - Start;
         -- Real_Took := Ada.Real_Time.Clock - Real_Start;
         -- Put_Line ("Sense: cpu " & Integer'Image (Took / Microseconds (1)) & " us  real " & Integer'Image (Real_Took / Microseconds (1)) & " us ");
         -- Put_Line ("Sense: job " & Job'Image & "  late " & Integer'Image (Late / Microseconds (1)) & " us");

         Next := Next + Period;
         delay until Next;
      end loop;
   end Scanner;

   protected body Latest is

      procedure Update (D : Distances) is
      begin
         Value := D;
      end Update;

      function Get return Distances is (Value);

   end Latest;

end Sense;
