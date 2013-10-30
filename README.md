bldc-tachometer
===============

An Arduino based brushless motor tachometer that uses one of the three motor wires as a signal. The signal to each wire on a brushless motor is a sinusoidal wave with frequency of 

frequency = (revolutions per second)*(number of poles) Hz. 

If the frequency can be measured, the motor RPM can be measured. 

However, brushless motor controllers power the motor with a high frequency PWM signal. The duty cycle of this signal determines the power transmitted to the motor. The PWM signal is not correlated with the RPM and it prevents the useful signal from being measured with a microcontroller interrupt. 

First, an optoisolator is used to convert the signal to a 0 or 5V logic level input. Unfortunately, the high frequency PWM from the motor controller makes this signal unintelligible. To fix this, a low pass filter is placed on the logic level side of the circuit to remove the high frequency input, leaving only the low frequency wave that correlates to motor speed. 

On the Arduino, an interrupt is used to count pulses and measure the wave frequency. The program has a simple output block that prints the RPM through the serial port. This can be customized to whatever you want.
