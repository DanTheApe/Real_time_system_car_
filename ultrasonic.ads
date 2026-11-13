-- AI Hevaly used for help here

with nRF.GPIO;        use nRF.GPIO;
with MicroBit.Types;  use MicroBit.Types;

generic
   Trigger_Pin : GPIO_Point;
   Echo_Pin    : GPIO_Point;
package Ultrasonic is

   function Read return Distance_cm;

end Ultrasonic;
