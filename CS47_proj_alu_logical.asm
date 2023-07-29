.include "./cs47_proj_macro.asm"
.text
.globl au_logical


#####################################################################
# Implement au_logical
# Argument:
# 	$a0: First number
#	$a1: Second number
#	$a2: operation code ('+':add, '-':sub, '*':mul, '/':div)
# Return:
#	$v0: ($a0+$a1) | ($a0-$a1) | ($a0*$a1):LO | ($a0 / $a1)
# 	$v1: ($a0 * $a1):HI | ($a0 % $a1)
# Notes:
#####################################################################
au_logical:

	#store RTE - 7 *4 = 28 bytes
	addi	$sp, $sp, -36
	sw	$fp, 36($sp)
	sw	$ra, 32($sp)
	sw	$a0, 28($sp)
	sw	$a1, 24($sp)
	sw	$a2, 20($sp)
	sw	$s0, 16($sp)
	sw	$s1, 12($sp)
	sw	$s2,  8($sp)
	addi	$fp, $sp, 36
	# body
	move 	$s0, $a0 #save the argument
	move 	$s1, $a1 #save the argument
	move 	$s2, $a2 #save the argument
	
	# Check which operation to perform
	beq	$s2, '+', add
	beq	$s2, '-', subtract
	beq	$s2, '*', multiply
	beq	$s2, '/', divide
	j	au_logical_ret   #if any other symbol is passed exit the procedure
	
	#add     $s1, $zero, $zero # store argument index
add:
	and	$a2, 0x00000000
	jal	add_sub_logic
	j	au_logical_ret
subtract:
	ori	$a2, 0xffffffff
	jal	add_sub_logic
	j	au_logical_ret
multiply:
	move	$a0, $s0
	jal	twos_complement_if_neg
	move	$s0, $v0
	move	$a0, $s1
	jal	twos_complement_if_neg
	move	$s1, $v0
	
	move	$a0, $s0
	move	$a1, $s1
	#jal	mul_unsigned
	j	au_logical_ret
	
divide:
	
	
au_logical_ret:
	#restore RTE
	lw	$fp, 36($sp)
	lw	$ra, 32($sp)
	lw	$a0, 28($sp)
	lw	$a1, 24($sp)
	lw	$a2, 20($sp)
	lw	$s0, 16($sp)
	lw	$s1, 12($sp)
	lw	$s2,  8($sp)
	addi	$sp, $sp, 36
	jr 	$ra
	
add_sub_logic:
	#store RTE - 7 *4 = 28 bytes
	addi	$sp, $sp, -36
	sw	$fp, 36($sp)
	sw	$ra, 32($sp)
	sw	$a0, 28($sp)
	sw	$a1, 24($sp)
	sw	$a2, 20($sp)
	sw	$s0, 16($sp)
	sw	$s1, 12($sp)
	sw	$s2,  8($sp)
	addi	$fp, $sp, 36
	# body
	and	$s2, $zero, $zero # $t0 = 0 --> index(I) 
	and	$t1, $zero, $zero # $t1 = 0 --> sum(S)
	extract_nth_bit($t2, $a2, $t0) # $t2 = $a2[0] --> carry(C)
	bne	$t2, 1, add_loop
	not	$a1, $a1
add_loop:
	and	$t3, $zero, $zero # $t3 = 0 --> Y
	extract_nth_bit($s0, $a0, $s2) # $s0 = $a0[I]
	extract_nth_bit($s1, $a1, $s2) # $s1 = $a1[I]
	add	$t4, $zero, $zero
	xor	$t4, $s0, $s1	# $t3(Y) = one bit add result of $a0[I] and $a1[I]
	xor	$t3, $t2, $t4	# $t3(Y) = one bit add result of $a0[I], $a1[I] and $t2->carry(C)
	and	$s1, $s1, $s0
	and	$s0, $t4, $t2
	or	$t2, $s0, $s1
	insert_to_nth_bit($t1, $s2, $t3, $t4)
	#move	$t1, $t3	# $t1(S) = $t3(Y)
	addi	$s2, $s2, 1	# $t0 += 1 --> index(I) 
	bne	$s2, 32, add_loop 
	move	$v0, $t1	# return $t1(Sum) in $v0
	move	$v1, $t2	# return $t2(final Carry Out) in $v1
add_sub_logic_ret:
	#restore RTE
	lw	$fp, 36($sp)
	lw	$ra, 32($sp)
	lw	$a0, 28($sp)
	lw	$a1, 24($sp)
	lw	$a2, 20($sp)
	lw	$s0, 16($sp)
	lw	$s1, 12($sp)
	lw	$s2,  8($sp)
	addi	$sp, $sp, 36
	jr 	$ra
twos_complement:
	#store RTE - 3 *4 = 12 bytes
	addi	$sp, $sp, -20
	sw	$fp, 20($sp)
	sw	$ra, 16($sp)
	sw	$a0, 12($sp)
	sw	$s0, 8($sp)
	addi	$fp, $sp, 20
	# body
	move	$s0, $a0
	not	$a0, $a0
	ori	$a1, $zero, 1
	and	$a2, $zero, $zero
	jal	add_sub_logic
twos_complement_ret:
	#restore RTE
	lw	$fp, 20($sp)
	lw	$ra, 16($sp)
	lw	$a0, 12($sp)
	lw	$s0, 8($sp)
	addi	$sp, $sp, 20
	jr 	$ra

twos_complement_if_neg:
	#store RTE - 3 *4 = 12 bytes
	addi	$sp, $sp, -20
	sw	$fp, 20($sp)
	sw	$ra, 16($sp)
	sw	$a0, 12($sp)
	sw	$s0, 8($sp)
	addi	$fp, $sp, 20
	# body
	move	$s0, $a0
	bgtz	$s0, not_neg
	jal	twos_complement
	j 	twos_complement_if_neg_ret
not_neg:
	move	$v0, $s0	
twos_complement_if_neg_ret:
	#restore RTE
	lw	$fp, 20($sp)
	lw	$ra, 16($sp)
	lw	$a0, 12($sp)
	lw	$s0, 8($sp)
	addi	$sp, $sp, 20
	jr 	$ra
	
twos_complement_64bit:
	#store RTE - 7 *4 = 28 bytes
	addi	$sp, $sp, -36
	sw	$fp, 36($sp)
	sw	$ra, 32($sp)
	sw	$a0, 28($sp)
	sw	$a1, 24($sp)
	sw	$a2, 20($sp)
	sw	$s0, 16($sp)
	sw	$s1, 12($sp)
	sw	$s2,  8($sp)
	addi	$fp, $sp, 36
	# body
	move	$s0, $a0	# $s0 = $a0
	move	$s1, $a1	# $s1 = $a1
	not	$a0, $a0	# $a0 = ~$a0
	ori	$a1, $zero, 1	# a1 = 1
	and	$a2, $zero, $zero	# a2 = 0
	jal	add_sub_logic
	move	$s0, $v0	# store $v0 in $s0
	not	$a0, $s1	# $a0 = ~upperbits 
	move	$a1, $v1	# $a1 = final carry out from add_sub_logic
	and	$a2, $zero, $zero # $a0 = 0 telling add_sub_logic to add $a0 and $a1
	jal	add_sub_logic
	move	$v0, $s0	# returning lower bits calculated previously in $v0
				# $v1 will automatically have the upper bits of 2s complement
twos_complement_64bit_ret:
	#restore RTE
	lw	$fp, 36($sp)
	lw	$ra, 32($sp)
	lw	$a0, 28($sp)
	lw	$a1, 24($sp)
	lw	$a2, 20($sp)
	lw	$s0, 16($sp)
	lw	$s1, 12($sp)
	lw	$s2,  8($sp)
	addi	$sp, $sp, 36
	jr 	$ra

bit_replicator:
	#store RTE - 3 *4 = 12 bytes
	addi	$sp, $sp, -20
	sw	$fp, 20($sp)
	sw	$ra, 16($sp)
	sw	$a0, 12($sp)
	sw	$s0, 8($sp)
	addi	$fp, $sp, 20
	# body
	move	$s0, $a0
	beqz 	$s0, bit_zero
	ori	$v0, $zero, 0xffffffff
	j	bit_replicator_ret
bit_zero:
	or	$v0, $zero, $zero
bit_replicator_ret:
	#restore RTE
	lw	$fp, 20($sp)
	lw	$ra, 16($sp)
	lw	$a0, 12($sp)
	lw	$s0, 8($sp)
	addi	$sp, $sp, 20
	jr 	$ra

mul_unsigned:
	#store RTE - 7 *4 = 28 bytes
	addi	$sp, $sp, -48
	sw	$fp, 48($sp)
	sw	$ra, 44($sp)
	sw	$a0, 40($sp)
	sw	$a1, 36($sp)
	sw	$a2, 32($sp)
	sw	$s0, 28($sp)
	sw	$s1, 24($sp)
	sw	$s2, 20($sp)
	sw	$s3, 16($sp)
	sw	$s4, 12($sp)
	sw	$s5, 8($sp)
	addi	$fp, $sp, 48
	# body
	move	$s0, $a0	# $s0 = $a0 (L)
	move	$s1, $a1	# $s1 = $a1 (M)
	and	$s2, $zero, $zero	# $s2(Index) = 0
	and	$s3, $zero, $zero	# $s3 (H) = 0
	and	$s4, $zero, $zero	# $s4 (R) = 0
	and	$s5, $zero, $zero	# $s5 (X) = 0
	and	$t0, $zero, $zero	# $t0 temp = 0	
mul_loop:
	extract_nth_bit($t0, $s0, $s2)
	move	$a0, $t0
	jal	bit_replicator
	move	$s4, $v0	# $s4(R) = 32{L[I]}
	and	$s5, $s1, $s4		# $s5(X) = $s1(M) and $s4(R)
	move	$a0, $s3	#$s3(H) = X($s5) + H($s3)	
	move	$a1, $s5	#$s3(H) = X($s5) + H($s3)
	and	$a2, $zero, $zero
	jal	add_sub_logic
	move	$s3, $v0	#$s3(H) = X($t4) + H($t1)
	srl	$s0, $s0, 1	# L($s0) = L >> 1
	and	$t1, $zero, $zero	# H[temp]; temp($t1) = 0
	extract_nth_bit($t2, $s3, $t1)
	ori	$t4, $zero, 31
	insert_to_nth_bit($s0, $t4, $t2, $t5) # ($s0)L[31] = H[0] ->($t2)
	srl	$s3, $s3, 1	# H = H >> 1

	addi	$s2, $s2, 1
	bne	$s2, 32, mul_loop
	move	$v0, $s0
	move	$v1, $s3
mul_unsigned_ret:
	#restore RTE
	lw	$fp, 48($sp)
	lw	$ra, 44($sp)
	lw	$a0, 40($sp)
	lw	$a1, 36($sp)
	lw	$a2, 32($sp)
	lw	$s0, 28($sp)
	lw	$s1, 24($sp)
	lw	$s2, 20($sp)
	lw	$s3, 16($sp)
	lw	$s4, 12($sp)
	lw	$s5, 8($sp)
	addi	$sp, $sp, 48
	jr 	$ra
