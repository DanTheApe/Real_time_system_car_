with Ada.Execution_Time; use type Ada.Execution_Time.CPU_Time;
with MicroBit.Console; use MicroBit.Console;

package body Think is
   Can_Go : constant Positive := 12;
   -- sjekker om noe er for nerme 20 cm
   function Blocked (D : Distances; S : Side) return Boolean is
     (D (S) < To_Close);
   -- sjekker om det er klart 30 cm
   function Open (D : Distances; S : Side) return Boolean is
     (D (S) >= Clear_Again);
   -- sjekker hvilken side har mer plass
   function Roomier (D : Distances) return Side is
     (if D (Right) > D (Left) then Right else Left);
   -- Prøve å snurre til finner en åpning
   function Way_Out (D : Distances) return Plan is
     (if not Blocked (D, Left) or else not Blocked (D, Right)
        then (Doing => Towards (Roomier (D)), Telling => 0)
      elsif not Blocked (D, Back)
        then (Doing => Go_Backward, Telling => 0)
      else (Doing => Halt, Telling => 0));

   function Drive_On (D : Distances) return Plan is
     (if Blocked (D, Front) then Way_Out (D)
      else (Doing => Go_Forward, Telling => 0));
   -- Hjerte funksjon: State maskin
   function Step (Now : Plan; D : Distances) return Plan is
      -- Trengte at bil sjekker at vei er ledig noen (12)(600ms) gange på rad. før snudde den og kjørte forbi obj med 1 cm. litt nerme.
      function Held (Clear_Now : Boolean) return Natural is
        (if Clear_Now then Now.Telling + 1 else 0);

   begin
      case Now.Doing is
         when Go_Forward =>
            if Blocked (D, Front) then
               return Way_Out (D);
            elsif Blocked (D, Left) and then Open (D, Right) then
               return (Doing => Go_Right, Telling => 0);
            elsif Blocked (D, Right) and then Open (D, Left) then
               return (Doing => Go_Left, Telling => 0);
            else
               return Now;
            end if;

         when Go_Left | Go_Right =>
            declare
               To : constant Side :=
                 (if Now.Doing = Go_Left then Left else Right);
               From : constant Side :=
                 (if Now.Doing = Go_Left then Right else Left);
            begin
               if Blocked (D, To) then
                  return Drive_On (D);
               elsif Held (Open (D, From)) >= Can_Go then
                  return Drive_On (D);
               else
                  return (Doing => Now.Doing, Telling => Held (Open (D, From)));
               end if;
            end;

         when Turn_Left | Turn_Right =>
            if Blocked (D, Left) and then Blocked (D, Right) then
               return Way_Out (D);
            elsif Held (Open (D, Front)) >= Can_Go then
               return (Doing => Go_Forward, Telling => 0);
            else
               return (Doing => Now.Doing, Telling => Held (Open (D, Front)));
            end if;

         when Go_Backward =>
            if Blocked (D, Back) then
               return (Doing => Halt, Telling => 0);
            elsif Held (Open (D, Left) or else Open (D, Right)) >= Can_Go
            then
               return (Doing => Towards (Roomier (D)), Telling => 0);
            else
               return (Doing  => Go_Backward,
                       Telling => Held (Open (D, Left) or else Open (D, Right)));
            end if;

         when Halt =>
            if Open (D, Front) then
               if Held (True) >= Can_Go then
                  return (Doing => Go_Forward, Telling => 0);
               else
                  return (Doing => Halt, Telling => Held (True));
               end if;
            else
               return Way_Out (D);
            end if;

      end case;
   end Step;

   task body Planner is
      Next : Time := Clock;
      Now : Plan;
      Start : Ada.Execution_Time.CPU_Time;
      Took : Time_Span;
      Real_Start : Time;
      Real_Took : Time_Span;
      Late  : Time_Span;
   begin
      loop
         -- Start := Ada.Execution_Time.Clock;
         -- Real_Start := Ada.Real_Time.Clock;
         -- Late := Real_Start - Next;

         Now := Step (Now, Latest.Get);
         Decision.Set (Now.Doing);

         -- Took := Ada.Execution_Time.Clock - Start;
         -- Real_Took := Ada.Real_Time.Clock - Real_Start;
         -- Put_Line ("Think: cpu " & Integer'Image (Took / Microseconds (1)) & " us  real " & Integer'Image (Real_Took / Microseconds (1)) & " us");
         -- Put_Line ("Think: late " & Integer'Image (Late / Microseconds (1)) & " us");

         Next := Next + Period;
         delay until Next;
      end loop;
   end Planner;

   protected body Decision is
      procedure Set (M : Move) is
      begin
         Value := M;
      end Set;

      function Get return Move is (Value);
   end Decision;

end Think;
