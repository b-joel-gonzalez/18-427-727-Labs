import utime
import uselect, sys, time
from servo import Servo
 
s1 = Servo(0)       # Servo pin is connected to GP0
spoll=uselect.poll()
spoll.register(sys.stdin,uselect.POLLIN)

def read1():
    return(sys.stdin.read(1) if spoll.poll(0) else None)

def servo_Map(x, in_min, in_max, out_min, out_max):
    return (x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min
 
def servo_Angle(angle):
    if angle < 0:
        angle = 0
    if angle > 180:
        angle = 180
    s1.goto(round(servo_Map(angle,0,180,0,1024))) # Convert range value to angle value

LED = machine.Pin(25, machine.Pin.OUT)
if __name__ == '__main__':
    while True:
        LED.toggle()
        utime.sleep(0.5)
        s1.stop()
        c = read1()
        if (c == "a"):
            s1.rotate_cw()
            utime.sleep_ms(300)