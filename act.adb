with Ada.Execution_Time;  use type Ada.Execution_Time.CPU_Time;
with MicroBit.Console;    use MicroBit.Console;

package body Act is

   task body Driver is
      Next : Time := Clock;
      Current : Move := Halt;
      The_Move : Move;
      Start : Ada.Execution_Time.CPU_Time;
      Took : Time_Span;
      Inter : Time_Span;
      Real_Start : Time;
      Real_Inter0 : Time_Span;
      Real_Inter1 : Time_Span;
      Drive_Start : Time;
      Late  : Time_Span;
   begin
      -- Drive_Start := Ada.Real_Time.Clock;
      Drive (Stop);
      -- Real_Inter1 := Ada.Real_Time.Clock - Drive_Start;
      -- Put_Line ("Act: board in " & Integer'Image (Real_Inter1 / Microseconds (1)) & " us");

      loop
         -- Start := Ada.Execution_Time.Clock;
         -- Real_Start := Ada.Real_Time.Clock;
         -- Late := Real_Start - Next;

         The_Move := Decision.Get;
         if The_Move /= Current then
            -- Drive_Start := Ada.Real_Time.Clock;
            -- Vad deilig å kunne skru av motoren når man skulle teste noe annet med usb (e.g. sensorer)
            if Motors_On then
               Drive (Motor_For (The_Move), Speed_For (The_Move));
            end if;
            -- Real_Inter1 := Ada.Real_Time.Clock - Drive_Start;

            -- Put_Line ("Act: " & The_Move'Image);
            -- Put_Line ("Act: " & Current'Image & " -> " & The_Move'Image & "  drive took " & Integer'Image (Real_Inter1 / Microseconds (1)) & " us");
            Current := The_Move;
         end if;

         -- Took := Ada.Execution_Time.Clock - Start;
         -- Real_Inter0 := Ada.Real_Time.Clock - Real_Start;
         -- Put_Line ("Act: cpu " & Integer'Image (Took / Microseconds (1)) & " us  real " & Integer'Image (Real_Inter0 / Microseconds (1)) & " us");
         -- Put_Line ("Act: late " & Integer'Image (Late / Microseconds (1)) & " us");

         Next := Next + Period;
         delay until Next;
      end loop;
   end Driver;

end Act;
