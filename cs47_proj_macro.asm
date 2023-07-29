# Add you macro definition here - do not touch cs47_common_macro.asm"
#<------------------ MACRO DEFINITIONS ---------------------->#

	# Macro : extract_nth_bit
	# Usage : extract_nth_bit(<result>, <reg>, <position>)
	.macro extract_nth_bit($res, $regD, $nth)
	#add	$res, $zero, $zero
	#addi	$res, $res, +31
	#sub	$res, $res, $nth
	
	addi	$res, $zero, 1
	SLLV	$res, $res, $nth
	and	$res, $regD, $res
	SRLV	$res, $res, $nth
	#or	$regD, $maskReg, $bit
	#SLLV	$t0, $reg, $res		# Shift LEFT Logical Variable
	#SRLV	$res, $reg, $res	# Shift Right Logical Variable
	#SRLV	$res, $reg, $nth	# Shift Right Logical Variable
	.end_macro 
	
	# Macro : insert_to_nth_bit
	# Usage : insert_to_nth_bit(<regD>, <position>, <$bit>, <$maskReg>)
	.macro insert_to_nth_bit($regD, $nth, $bit, $maskReg)
	addi	$maskReg, $zero, +1
	SLLV	$maskReg, $maskReg, $nth
	not	$maskReg, $maskReg
	and	$maskReg, $regD, $maskReg
	SLLV	$bit, $bit, $nth
	or	$regD, $maskReg, $bit
	.end_macro 
