with Ada.Real_Time; use Ada.Real_Time;
with MicroBit.MotorDriver; use MicroBit.MotorDriver;
with Think; use Think;

package Act is
   Period: constant Time_Span := Milliseconds (50);
   Motors_On: constant Boolean := True;
   Cruise_Speed: constant Speeds := (others => 3000);
   Circle_Speed: constant Speeds := (lf | lb => 3000, rf | rb => 1500);
   Speed_For: constant array (Move) of Speeds := (Go_Forward => Circle_Speed, others => Cruise_Speed);

   Motor_For: constant array (Move) of Directions :=
     (Go_Forward => Forward,
      Go_Backward => Backward,
      Go_Left => Left,
      Go_Right => Right,
      Turn_Left => Rotating_Left,
      Turn_Right => Rotating_Right,
      Halt => Stop);

   task Driver with Priority => 1;

end Act;
