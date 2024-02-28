@ +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
@
@        Library Name:           
@								Klib-io (for RealDigital Blackboard)
@        
@        Version:                
@								1.0.0 
@
@        Contributor(s):         
@								Koby Miller
@
@        Date last modified:     
@								February 26th, 2024
@
@ +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+

.ifndef KLIB_IO_ARM_ASSEMBLY_
.set KLIB_IO_ARM_ASSEMBLY_, 1

@ GPIO Addresses
.set BUTTONS, 0x41200000
.set LEDS, 0x41210000
.set SEVSEG, 0x43C10000
.set SWITCHES, 0x41220000

@ PMOD B Addresses
.set DATA_2, 0xE000A048
.set DATA_2_RO, 0xE000A068
.set DIR_2, 0xE000A284
.set OE_2, 0xE000A288
.set PMODB_TOP_MASK, 0x0780
.set PMODB_BOTTOM_MASK, 0x7800

.text
@ +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
@ setupSevSeg
@ Enable seven-segment display in default mode
@
@	No parameters
@
@	No return value
@
@ Written by Koby Miller
@ Last modified: February 22nd, 2024
@ +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
setupSevSeg:
	@ *((unsigned int*)SEVSEG) = 0b01;
	@ r0 = 0x43C10000;
	ldr r0, =SEVSEG
	mov r1, #0b01

	@ writing 0b01 to address 0x43C10000 (which is r0)
	str r1, [ r0 ]

	@ branch and exchange -- set program counter to link-register value
	@ return;
bx lr

@ +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
@ outputToSevSeg
@ Writes data to the seven-segment display
@
@ 	r1		parameter -> value to write to seven-segment
@
@	No return value
@
@ Written by Koby Miller
@ Last modified: February 22nd, 2024
@ +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
outputToSevSeg:
	push {r0,lr}

	@ preserve previous link-register value
	bl formatSevSegData
	@ restore stored link-register value

	mov r1, r0

	@ *((unsigned int*)SEVSEG + 1) = 0b01;
	ldr r0, =SEVSEG

	str r1, [ r0, #0x4 ]	@ store r1 to r0 + 0x4

	pop {r0,lr}

bx lr

@ +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
@ formatSevSegData
@ Formats data to be written to the seven-segment display
@
@ 	r1		parameter -> value to write to seven-segment
@
@	r0		return -> formatted value
@
@ Written by Koby Miller
@ Last modified: February 22nd, 2024
@ +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
formatSevSegData:

	@ r0 = r1 & 0xF;
	and r0, r1, #0xF

	push {r2}

	@ r0 = r0 | ((r1 & 0xF0) << 4)
	and r2, r1, #0xF0
	orr r0, r0, r2, lsl #4

	pop {r2}

bx lr

@ +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
@ outputToLEDs
@ Writes data to on-board LEDs
@
@ 	r1		parameter -> value to write to the LEDs
@
@	No return value
@
@ Written by Koby Miller
@ Last modified: February 22nd, 2024
@ +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
outputToLEDs:
	push {r0}
	ldr r0, =LEDS
	str r1, [r0]
	pop {r0}

bx lr

@ +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
@ getButtonStates
@ Gets current state of on-board pushbuttons
@
@ 	No parameters
@
@	r0		return -> button states
@
@ Written by Koby Miller
@ Last modified: February 22nd, 2024
@ +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
getButtonStates:
	push {r1}
	ldr r1, =BUTTONS
	ldr r0, [r1]
	pop {r1}
	
bx lr

@ +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
@ getSwitchStates
@ Gets current state of on-board switches
@
@ 	No parameters
@
@	r0		return -> button states
@
@ Written by Koby Miller
@ Last modified: February 22nd, 2024
@ +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
getSwitchStates:
	push {r1}
	ldr r1, =SWITCHES
	ldr r0, [r1]
	pop {r1}
	
bx lr

@ +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
@ setupPmod
@ Gets current state of on-board switches
@
@ 	r1		parameter -> i/o (0 for input (read), 1 for output(write))
@ 	r2		parameter -> row (0 for top, 1 for bottom)
@
@	No return values
@
@ Written by Koby Miller
@ Last modified: February 22nd, 2024
@ +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
setupPmod:
	push {r3,r4}

@ Equivalent C code
@
@	void setupPmod(bool io, bool row) {
@
@    if(row == 0) {
@        if(io == 0) {   // bits 7-10 of DIR_2 for top row should be 0000 for input
@            *((unsigned int*)DIR_2) &= ~PMODB_TOP_MASK;
@            *((unsigned int*)OE_2) &= ~PMODB_TOP_MASK;
@
@        } else {        // bits 7-10 of DIR_2 for top row should be 1111 for output
@            *((unsigned int*)DIR_2) |= PMODB_TOP_MASK;
@            *((unsigned int*)OE_2) |= PMODB_TOP_MASK;
@
@        }   
@
@    } else {
@        if(io == 0) {   // bits 11-14 of DIR_2 for bopttom row should be 0000 for input
@            *((unsigned int*)DIR_2) &= ~PMODB_BOTTOM_MASK;
@            *((unsigned int*)OE_2) &= ~PMODB_BOTTOM_MASK;
@
@        } else {        // bits 11-14 of DIR_2 for bottom row should be 1111 for output
@            *((unsigned int*)DIR_2) |= PMODB_BOTTOM_MASK;
@            *((unsigned int*)OE_2) |= PMODB_BOTTOM_MASK;
@            
@        }
@    }
@
@    return;
@}
	
	cmp r2, #0
	beq topRowSetup
	b bottomRowSetup
	
	topRowSetup:
		cmp r1, #0
		beq topRowInput
		b topRowOutput
		
		topRowInput:
			
			ldr r3, =PMODB_TOP_MASK
			mvn r3, r3
			and r4, r4, r3
			
			ldr r3, =OE_2
			str r4, [r3]
			
			ldr r3, =PMODB_TOP_MASK
			mvn r3, r3
			and r4, r4, r3
			
			ldr r3, =DIR_2
			str r4, [r3]
			
			b leaveSetupPmod
			
		topRowOutput:
			
			ldr r3, =PMODB_TOP_MASK
			orr r4, r4, r3
		
			ldr r3, =OE_2
			str r4, [r3]
			
			ldr r3, =PMODB_TOP_MASK
			orr r4, r4, r3
			
			ldr r3, =DIR_2
			str r4, [r3]
		
			b leaveSetupPmod
	
	bottomRowSetup:
		cmp r1, #0
		beq bottomRowInput
		b bottomRowOutput
		
		bottomRowInput:
			
			ldr r3, =PMODB_BOTTOM_MASK
			mvn r3, r3
			and r4, r4, r3
			
			ldr r3, =OE_2
			str r4, [r3]
			
			ldr r3, =PMODB_BOTTOM_MASK
			mvn r3, r3
			and r4, r4, r3
			
			ldr r3, =DIR_2
			str r4, [r3]
		
			b leaveSetupPmod
			
		bottomRowOutput:
			
			ldr r3, =PMODB_BOTTOM_MASK
			orr r4, r4, r3
		
			ldr r3, =OE_2
			ldr r4, [r3]
			
			ldr r3, =PMODB_BOTTOM_MASK
			orr r4, r4, r3
			
			ldr r3, =DIR_2
			str r4, [r3]
		
			@b leaveSetupPmod
		
	leaveSetupPmod:
		pop {r3,r4}
bx lr

@ +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
@ pmodRead
@ Gets current state of on-board switches
@
@ 	r1		parameter -> row (0 for top, 1 for bottom)
@
@	r0		return value -> read PMOD value
@
@ Written by Koby Miller
@ Last modified: February 22nd, 2024
@ +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
pmodRead:
	push {r2,r3,r4,lr}
	
@ Equivalent C code
@
@unsigned int pmodRead(bool row) {
@
@    unsigned int data = 0;
@
@    setupPmod(0, row); // ensure input mode
@
@    if(row == 0) { // top row
@        data = (*((unsigned int*)DATA_2_RO) & PMODB_TOP_MASK) >> 7; // mask off and shift to appropriate bit position
@       
@    } else { // bottom row
@        data = (*((unsigned int*)DATA_2_RO) & PMODB_BOTTOM_MASK) >> 11; // mask off and shift to appropriate bit position
@
@    }
@
@    return data;
@}
	
	mov r2, r1
	mov r1, #0
	bl setupPmod
	
	cmp r2, #0
	beq topRowPmodRead
	b bottomRowPmodRead
	
	topRowPmodRead:
		ldr r3, =DATA_2_RO
		ldr r4, [r3]
		
		and r4, r4, #PMODB_TOP_MASK
		lsr r4, #7
		
		b leavePmodRead
		
	bottomRowPmodRead:
		ldr r3, =DATA_2_RO
		ldr r4, [r3]
		
		and r4, r4, #PMODB_BOTTOM_MASK
		lsr r4, #11
		
		@b leavePmodRead
		
	leavePmodRead:
		mov r0, r4
		pop {r2,r3,r4,lr}
bx lr


@ +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
@ pmodWrite
@ Gets current state of on-board switches
@
@ 	r1		parameter -> row (0 for top, 1 for bottom)
@	r2		parameter -> data to write to PMOD
@
@	No return values
@
@ Written by Koby Miller
@ Last modified: February 22nd, 2024
@ +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
pmodWrite:
	push {r3,r4,r5,lr}

@ Equivalent C code
@
@void pmodWrite(bool row, unsigned int data) {
@
@    setupPmod(1, row); // ensure output mode
@
@    if(row == 0) { // top row
@        *((unsigned int*) DATA_2) = (*((unsigned int*)DATA_2) & ~PMODB_TOP_MASK) | ((data << 7) & PMODB_TOP_MASK);	
@
@    } else { // bottom row
@        *((unsigned int*) DATA_2) = (*((unsigned int*)DATA_2) & ~PMODB_BOTTOM_MASK) | ((data << 11) & PMODB_BOTTOM_MASK);
@
@    }
@
@    return;
@}

	mov r5, r2

	mov r2, r1
	mov r1, #1
	bl setupPmod
	
	cmp r2, #0
	beq topRowPmodWrite
	b bottomRowPmodWrite
	
	topRowPmodWrite:
		ldr r3, =DATA_2
		ldr r4, [r3]
		
		ldr r3, =PMODB_TOP_MASK
		mvn r3, r3
		
		and r4, r4, r3
		
		lsl r5, #7
		and r5, r5, #PMODB_TOP_MASK
		orr r4, r4, r5

		b leavePmodWrite
		
	bottomRowPmodWrite:
		ldr r3, =DATA_2
		ldr r4, [r3]
		
		ldr r3, =PMODB_BOTTOM_MASK
		mvn r3, r3
		
		and r4, r4, r3
		
		lsl r5, #11
		and r5, r5, #PMODB_BOTTOM_MASK
		orr r4, r4, r5
		
		@b leavePmodWrite
		
	leavePmodWrite:
		ldr r3, =DATA_2
		str r4, [r3]
		
		pop {r3,r4,r5,lr}
bx lr

@ +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
@ dummyTimer
@ Waits however long it takes the board to count from 0xFFFF to zero
@ "A timer for dummies!"
@
@ 	No parameters
@
@	No return values
@
@ Written by Koby Miller
@ Last modified: February 23rd, 2024
@ +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
dummyTimer:

	push {r0}
	
	mov r0, #0xFFFF
	
	DummyTimerLoop:
		@ Literal nonsense
		sub r0, r0, #1
	
	cmp r0, #0
	bge DummyTimerLoop
	
	pop {r0}

bx lr

@ +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
@ intDivide
@ Perform integer division
@
@	r1		parameter -> operand one
@	r2		parameter -> operand two
@
@	r0 		return -> integer quotient
@
@ Written by Koby Miller
@ Last modified: February 28th, 2024
@ +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
intDivide:
	push {r3,r4,r5,r6}
	mov r3, r1 @ create a copy of operand one, also used as remainder
	mov r4, r2 @ create a copy of operand two
	mov r6, #0 @ counter
	
	cmp r1, #0	@ determine if first operand is positive or negative
	bge posDivOperandOne
	ble negDivOperandOne
	beq leaveIntDivide
	
	posDivOperandOne:
		cmp r2, #0 @ determine to count positive or negative
		movge r5, #1 @ if positive
		movle r5, #-1 @ if negative
		suble r4, r4, #1 @ make positive part 1
		mvnle r4, r4 @ make positive part 2
		beq leaveIntDivide @ if dividing by zero
		
	posDivOperandOneLoop:

		sub r3, r3, r4 @ subtract operand two from operand one over and over until zero or negative

	cmp r3, #0 @ loop and count check
	addge r6, r6, r5 @ increment counter
	bge posDivOperandOneLoop
	b leaveIntDivide @ break
	
	negDivOperandOne:
		cmp r2, #0 
		
		movge r5, #-1 @ if positive
		
		movle r5, #1 @ if negative
		
		suble r4, r4, #1 @ make negative part 1
		mvnle r4, r4 @ make negative part 2
		beq leaveIntDivide @ if dividing by zero
		
	negDivOperandOneLoop:
	
		add r3, r3, r4  @ add operand one and operand two over and over until zero or positive
	
	cmp r3, #0 @ loop and count check
	addle r6, r6, r5 @ increment counter
	ble negDivOperandOneLoop
	@b leaveIntDivide @ break
	
	leaveIntDivide:
	mov r0, r6
	pop {r3,r4,r5,r6}
bx lr

@ +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
@ intMod
@ Perform integer modulus 
@
@	r1		parameter -> operand one
@	r2		parameter -> operand two
@
@	r0 		return -> integer remainder
@
@ Written by Koby Miller
@ Last modified: February 26th, 2024
@ +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
intMod:
	push {r3,r4}
	mov r3, r1 @ create a copy of operand one, also used as remainder
	mov r4, r2 @ create a copy of operand two

	cmp r2, #0 @ if dividing by zero
	beq leaveIntMod

	cmp r1, #0 	@ determine if first operand is positive or negative
	bge posModOperandOne
	ble negModOperandOne
	beq leaveIntMod @ break

	posModOperandOne:

		sub r3, r3, r4 @ subtract operand two from operand one over and over until zero or negative

	cmp r3, #0
	addle r3, r3, r4 @ step back one so that it is correct remainder
	bge posModOperandOne

	b leaveIntMod

	negModOperandOne:

		add r3, r3, r4 @ add operand one and operand two over and over until zero or positive

	cmp r3, #0
	subge r3, r3, r4 @ step back one so that it is correct remainder
	ble negModOperandOne
	@b leaveIntMod @ break

	leaveIntMod:
	mov r0, r3
	pop {r3,r4}
bx lr

@ +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
@ EoF
@ +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
.endif 