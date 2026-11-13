with Ada.Real_Time; use Ada.Real_Time;
with MicroBit.Types; use MicroBit.Types;
with Sense; use Sense;

package Think is
   To_Close: constant Distance_cm := 20;
   Clear_Again: constant Distance_cm := 30;

   Clear_For: constant Time_Span := Milliseconds (600);
   Period: constant Time_Span := Milliseconds (50);

   type Move is (Go_Forward, Go_Backward, Go_Left, Go_Right, Turn_Left, Turn_Right, Halt);

   function Towards (S : Side) return Move is
     (case S is
         when Front => Go_Forward,
         when Back  => Go_Backward,
         when Left  => Turn_Left,
         when Right => Turn_Right);

   -- Trengte Telling slik at bil ikke kjørte 1 cm fra object/vegg på siden ()
   type Plan is record
      Doing: Move    := Halt;
      Telling: Natural := 0;
   end record;

   function Step (Now : Plan; D : Distances) return Plan
     with Post =>
       (case Step'Result.Doing is
           when Go_Forward => D (Front) >= To_Close,
           when Go_Backward => D (Back) >= To_Close,
           when Go_Left => D (Left) >= To_Close,
           when Go_Right => D (Right) >= To_Close,
           when Turn_Left | Turn_Right => D (Left) >= To_Close or else D (Right) >= To_Close,
           when Halt => True);

   protected Decision is
      procedure Set (M : Move);
      function Get return Move;
   private
      Value : Move := Halt;
   end Decision;
   task Planner with Priority => 2;
end Think;
