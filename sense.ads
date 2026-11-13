with Ada.Real_Time; use Ada.Real_Time;
with MicroBit; use MicroBit;
with MicroBit.Types; use MicroBit.Types;
with nRF.GPIO;

package Sense is
   -- Tidlig hadde vi ikke 4 sensorer so lagde denne
   type Side is (Front, Back, Left, Right);
   Installed : constant array (Side) of Boolean :=
     (Front => True,
      Back => True,
      Left => True,
      Right => True);

   Front_Trigger: nRF.GPIO.GPIO_Point renames MB_P0;
   Front_Echo: nRF.GPIO.GPIO_Point renames MB_P1;

   Back_Trigger: nRF.GPIO.GPIO_Point renames MB_P2;
   Back_Echo: nRF.GPIO.GPIO_Point renames MB_P16;

   Left_Trigger: nRF.GPIO.GPIO_Point renames MB_P14;
   Left_Echo: nRF.GPIO.GPIO_Point renames MB_P15;

   Right_Trigger: nRF.GPIO.GPIO_Point renames MB_P12;
   Right_Echo: nRF.GPIO.GPIO_Point renames MB_P13;


   Period : constant Time_Span := Milliseconds (200);
   Waiter : constant Time_Span := Milliseconds (10);
   -- Array med sidene med cm avstand fra 0 til 400
   type Distances is array (Side) of Distance_cm;
   -- Nothing_Seen blir satt til 400
   -- Nothing_Seen er ugjykldige echo fra sensor (unde 2cm, over 400cm)
   Nothing_Seen : constant Distance_cm := Distance_cm'Last;

   protected Latest is procedure Update (D : Distances);
      function Get return Distances;
   private
      Value : Distances := (others => 0);
   end Latest;
   task Scanner with Priority => 3;

end Sense;
