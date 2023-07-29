.include "./cs47_proj_macro.asm"
.include "./cs47_common_macro.asm"
# data section
.data 
.align 2
addMsg: .asciiz "add"
.text
.globl au_normal

#####################################################################
# Implement au_normal
# Argument:
# 	$a0: First number
#	$a1: Second number
#	$a2: operation code ('+':add, '-':sub, '*':mul, '/':div)
# Return:
#	$v0: ($a0+$a1) | ($a0-$a1) | ($a0*$a1):LO | ($a0 / $a1)
# 	$v1: ($a0 * $a1):HI | ($a0 % $a1)
# Notes:
#####################################################################
au_normal:

	# Save the arguements 
	move	$t0, $a0
	move	$t1, $a1
	move	$t2, $a2
	
	# Check which operation to perform
	beq	$t2, '+', add
	beq	$t2, '-', subtract
	beq	$t2, '*', multiply
	beq	$t2, '/', divide
	j	else
add:
	add	$v0, $t0, $t1
	j	else
subtract:
	sub	$v0, $t0, $t1
	j	else
multiply:
	mul 	$v0, $t0, $t1
	mfhi	$v1
	j	else
divide:	
	div  	$t0, $t1
	mflo	$v0
	mfhi	$v1
else:
	#Return to the caller
	jr	$ra
